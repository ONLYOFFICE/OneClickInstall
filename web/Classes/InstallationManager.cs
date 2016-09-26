/*
 *
 * (c) Copyright Ascensio System Limited 2010-2015
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations under the License.
 *
 * You can contact Ascensio System SIA by email at sales@onlyoffice.com
 *
*/

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using OneClickInstallation.Helpers;
using OneClickInstallation.Models;
using Renci.SshNet;
using log4net;

namespace OneClickInstallation.Classes
{
    public class InstallationManager : IDisposable
    {
        private string UserId { get; set; }
        private string LicenseKey { get; set; }
        private bool Enterprise { get; set; }

        private ConnectionInfo ConnectionInfo { get; set; }
        private InstallationProgressModel InstallationProgress { get; set; }
        private InstallationComponentsModel InstallationComponents { get; set; }
        private InstallationComponentsModel InstalledComponents { get; set; }

        private SshClient _sshClient;
        private SftpClient _sftpClient;

        private SshClient SshClient
        {
            get
            {
                if (_sshClient == null)
                    _sshClient = new SshClient(ConnectionInfo);

                if (_sshClient.IsConnected) return _sshClient;

                _sshClient.Connect();
                _sshClient.KeepAliveInterval = TimeSpan.FromMinutes(30);

                return _sshClient;
            }
        }

        private SftpClient SftpClient
        {
            get
            {
                if (_sftpClient == null)
                    _sftpClient = new SftpClient(ConnectionInfo);
                
                if (_sftpClient.IsConnected) return _sftpClient;
                
                _sftpClient.Connect();
                _sftpClient.KeepAliveInterval = TimeSpan.FromMinutes(30);

                UpdateAuth();

                return _sftpClient;
            }
        }

        private void UpdateAuth()
        {
            if (UserId == ConnectionInfo.Host) return;

            UserId = ConnectionInfo.Host;

            CookieHelper.SetCookie(UserId);
        }

        public InstallationManager(string userId, ConnectionSettingsModel connectionSettings, InstallationComponentsModel installationComponents = null)
        {
            UserId = userId;
            LicenseKey = connectionSettings.LicenseKey;
            Enterprise = connectionSettings.Enterprise;
            ConnectionInfo = GetConnectionInfo(connectionSettings);
            InstallationProgress = CacheHelper.GetInstallationProgress(userId) ?? new InstallationProgressModel();
            InstallationComponents = installationComponents;
            InstalledComponents = CacheHelper.GetInstalledComponents(userId) ?? new InstallationComponentsModel();
        }

        public void StartInstallation()
        {
            try
            {
                if (InstallationComponents.IsEmpty) return;

                UploadFiles();

                var osInfo = GetOsInfo(FileMap.GetOsInfoScript, InstallationProgressStep.GetOsInfo);

                if (Settings.MakeSwap)
                    MakeSwap();

                CheckPorts();

                InstallDocker(osInfo);

                CreateNetwork();

                InstallDocumentServer();

                InstallMailServer();

                if (Enterprise)
                    InstallControlPanel();

                InstallCommunityServer();

                CheckPreviousVersion(FileMap.CheckPreviousVersionScript, true);

                WarmUp();
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);
                InstallationProgress.ErrorMessage += ex.Message;
            }
            finally
            {
                InstallationProgress.IsCompleted = true;
                InstallationProgress.Step = InstallationProgressStep.End;
                CacheHelper.SetInstallationProgress(UserId, InstallationProgress);
                FileHelper.CreateLogFile(UserId, InstallationProgress);
            }
        }

        public Tuple<OsInfo, InstallationComponentsModel> Connect()
        {
            var tmpCheckPreviousVersionScript = new FileMap("~/Executables/tools/check-previous-version.sh", "./");
            var tmpGetOsInfoScript = new FileMap("~/Executables/tools/get-os-info.sh", "./");

            UploadFile(tmpCheckPreviousVersionScript, tmpGetOsInfoScript);

            CheckPreviousVersion(tmpCheckPreviousVersionScript, false);
            var osInfo = GetOsInfo(tmpGetOsInfoScript, null);

            SftpClient.DeleteFile(tmpCheckPreviousVersionScript.RemotePath);
            SftpClient.DeleteFile(tmpGetOsInfoScript.RemotePath);

            return new Tuple<OsInfo, InstallationComponentsModel>(osInfo, CacheHelper.GetInstalledComponents(UserId));
        }

        private static ConnectionInfo GetConnectionInfo(ConnectionSettingsModel connectionSettings)
        {
            var authenticationMethods = new List<AuthenticationMethod>();

            if (!string.IsNullOrEmpty(connectionSettings.Password))
            {
                authenticationMethods.Add(new PasswordAuthenticationMethod(connectionSettings.UserName, connectionSettings.Password));
            }

            if (!string.IsNullOrEmpty(connectionSettings.SshKey))
            {
                var keyFiles = new[] { new PrivateKeyFile(FileHelper.GetFile(connectionSettings.SshKey)) };
                authenticationMethods.Add(new PrivateKeyAuthenticationMethod(connectionSettings.UserName, keyFiles));
            }

            return new ConnectionInfo(connectionSettings.Host, connectionSettings.UserName, authenticationMethods.ToArray());
        }

        private void UploadFiles()
        {
            InstallationProgress.Step = InstallationProgressStep.UploadFiles;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            CreateDirectories();

            var files = new List<FileMap>
                {
                    FileMap.RunDockerScript,

                    FileMap.CheckBindingsScript,
                    FileMap.CheckPortsScript,
                    FileMap.CheckPreviousVersionScript,
                    FileMap.GetAvailableVersionScript,
                    FileMap.GetOsInfoScript,
                    FileMap.LoginDockerScript,
                    FileMap.MakeDirScript,
                    FileMap.MakeNetworkScript,
                    FileMap.MakeSwapScript,
                    FileMap.PullImageScript,
                    FileMap.RemoveContainerScript,

                    FileMap.RunCommunityServerScript,
                    FileMap.RunControlPanelScript,
                    FileMap.RunDocumentServerScript,
                    FileMap.RunMailServerScript
                };

            if (Enterprise && Settings.EnterpriseLicenseRequired && !string.IsNullOrEmpty(LicenseKey))
            {
                files.Add(FileMap.MakeLicenseFileMap(LicenseKey, "DocumentServer"));
                files.Add(FileMap.MakeLicenseFileMap(LicenseKey, "MailServer"));
                files.Add(FileMap.MakeLicenseFileMap(LicenseKey, "CommunityServer"));
                files.Add(FileMap.MakeLicenseFileMap(LicenseKey, "ControlPanel"));
            }

            UploadFile(files.ToArray());
        }

        private void UploadFile(params FileMap[] files)
        {
            foreach (var file in files)
            {
                if (!SftpClient.Exists(file.RemoteDir))
                    SftpClient.CreateDirectory(file.RemoteDir);

                SftpClient.ChangeDirectory(file.RemoteDir);

                using (var fileStream = File.OpenRead(file.LocalPath))
                {
                    SftpClient.UploadFile(fileStream, file.IsScriptFile ? file.FileName : "license.lic", true);
                }
            }

            ChangeScriptFile(SshClient, files);
        }

        private void CreateDirectories()
        {
            var tmpScript = new FileMap("~/Executables/tools/make-dir.sh", "./");

            UploadFile(tmpScript);

            MakeDirectories(tmpScript);

            SftpClient.DeleteFile(tmpScript.RemotePath);
        }

        private OsInfo GetOsInfo(FileMap script, InstallationProgressStep? progressStep)
        {
            var output = RunScript(progressStep,
                script,
                true,
                Settings.RequirementsDisk.ToString(CultureInfo.InvariantCulture),
                Settings.RequirementsMemory.ToString(CultureInfo.InvariantCulture),
                Settings.RequirementsCore.ToString(CultureInfo.InvariantCulture));

            var osInfo = new OsInfo
                {
                    Dist = GetTerminalParam(output, "DIST"),
                    Ver = GetTerminalParam(output, "REV"),
                    Type = GetTerminalParam(output, "MACH"),
                    Kernel = GetTerminalParam(output, "KERNEL"),
                    Disk = int.Parse(GetTerminalParam(output, "DISK")),
                    Memory = int.Parse(GetTerminalParam(output, "MEMORY")),
                    Core = int.Parse(GetTerminalParam(output, "CORE"))
                };

            CacheHelper.SetOsInfo(UserId, osInfo);

            return osInfo;
        }

        private void MakeSwap()
        {
            RunScript(null, FileMap.MakeSwapScript, true);
        }

        private void CheckPorts()
        {
            var ports = new List<int>();

            if (!string.IsNullOrEmpty(InstallationComponents.CommunityServerVersion) && string.IsNullOrEmpty(InstalledComponents.CommunityServerVersion))
                ports.AddRange(new[] {80, 443, 5222});

            if (!string.IsNullOrEmpty(InstallationComponents.MailServerVersion) && string.IsNullOrEmpty(InstalledComponents.MailServerVersion))
                ports.AddRange(new[] {25, 143, 587});

            if (ports.Count > 0)
                RunScript(InstallationProgressStep.CheckPorts, FileMap.CheckPortsScript, string.Join(",", ports));
        }

        private void MakeDirectories(FileMap script)
        {
            RunScript(null, script);
        }

        private void CheckPreviousVersion(FileMap script, bool useSudo)
        {
            var output = RunScript(null,
                                   script,
                                   useSudo,
                                   "-cc " + Settings.DockerCommunityContainerName,
                                   "-dc " + Settings.DockerDocumentContainerName,
                                   "-mc " + Settings.DockerMailContainerName,
                                   "-cpc " + Settings.DockerControlPanelContainerName);

            InstallationComponents = new InstallationComponentsModel
            {
                MailServerVersion = GetTerminalParam(output, "MAIL_SERVER_VERSION"),
                DocumentServerVersion = GetTerminalParam(output, "DOCUMENT_SERVER_VERSION"),
                CommunityServerVersion = GetTerminalParam(output, "COMMUNITY_SERVER_VERSION"),
                ControlPanelVersion = GetTerminalParam(output, "CONTROL_PANEL_VERSION"),
                LicenseFileExist = bool.Parse(GetTerminalParam(output, "LICENSE_FILE_EXIST"))
            };

            CacheHelper.SetInstalledComponents(UserId, InstallationComponents.IsEmpty ? null : InstallationComponents);
        }

        private void InstallDocker(OsInfo osInfo)
        {
            RunScript(InstallationProgressStep.InstallDocker,
                      FileMap.RunDockerScript,
                      true,
                      "\"" + osInfo.Dist + "\"",
                      osInfo.Ver,
                      osInfo.Kernel,
                      osInfo.Type);
        }

        private void CreateNetwork()
        {
            RunScript(null, FileMap.MakeNetworkScript, true);
        }

        private void InstallCommunityServer()
        {
            if (string.IsNullOrEmpty(InstallationComponents.CommunityServerVersion)) return;

            RunScript(InstallationProgressStep.InstallCommunityServer,
                          FileMap.RunCommunityServerScript,
                          "-i " + (Enterprise ? Settings.DockerEnterpriseCommunityImageName : Settings.DockerCommunityImageName),
                          "-v " + InstallationComponents.CommunityServerVersion,
                          "-c " + Settings.DockerCommunityContainerName,
                          "-dc " + Settings.DockerDocumentContainerName,
                          "-mc " + Settings.DockerMailContainerName,
                          "-cc " + Settings.DockerControlPanelContainerName,
                          "-p " + Settings.DockerHubPassword,
                          "-un " + Settings.DockerHubUserName,
                          string.IsNullOrEmpty(InstalledComponents.CommunityServerVersion) ? string.Empty : "-u");

            InstalledComponents.CommunityServerVersion = InstallationComponents.CommunityServerVersion;
            CacheHelper.SetInstalledComponents(UserId, InstalledComponents);
        }

        private void InstallDocumentServer()
        {
            if (string.IsNullOrEmpty(InstallationComponents.DocumentServerVersion)) return;

            RunScript(InstallationProgressStep.InstallDocumentServer,
                          FileMap.RunDocumentServerScript,
                          "-i " + (Enterprise ? Settings.DockerEnterpriseDocumentImageName : Settings.DockerDocumentImageName),
                          "-v " + InstallationComponents.DocumentServerVersion,
                          "-c " + Settings.DockerDocumentContainerName,
                          "-p " + Settings.DockerHubPassword,
                          "-un " + Settings.DockerHubUserName,
                          string.IsNullOrEmpty(InstalledComponents.DocumentServerVersion) ? string.Empty : "-u");

            InstalledComponents.DocumentServerVersion = InstallationComponents.DocumentServerVersion;
            CacheHelper.SetInstalledComponents(UserId, InstalledComponents);
        }

        private void InstallMailServer()
        {
            if (string.IsNullOrEmpty(InstallationComponents.MailServerVersion)) return;

            RunScript(InstallationProgressStep.InstallMailServer,
                          FileMap.RunMailServerScript,
                          "-i " + (Enterprise ? Settings.DockerEnterpriseMailImageName : Settings.DockerMailImageName),
                          "-v " + InstallationComponents.MailServerVersion,
                          "-c " + Settings.DockerMailContainerName,
                          string.IsNullOrEmpty(InstallationComponents.MailDomain) ? string.Empty : "-d " + InstallationComponents.MailDomain,
                          "-p " + Settings.DockerHubPassword,
                          "-un " + Settings.DockerHubUserName,
                          string.IsNullOrEmpty(InstalledComponents.MailServerVersion) ? string.Empty : "-u");

            InstalledComponents.MailServerVersion = InstallationComponents.MailServerVersion;
            CacheHelper.SetInstalledComponents(UserId, InstalledComponents);
        }

        private void InstallControlPanel()
        {
            if (string.IsNullOrEmpty(InstallationComponents.ControlPanelVersion)) return;

            RunScript(InstallationProgressStep.InstallControlPanel,
                          FileMap.RunControlPanelScript,
                          "-i " + (Enterprise ? Settings.DockerEnterpriseControlPanelImageName : Settings.DockerControlPanelImageName),
                          "-v " + InstallationComponents.ControlPanelVersion,
                          "-c " + Settings.DockerControlPanelContainerName,
                          "-p " + Settings.DockerHubPassword,
                          "-un " + Settings.DockerHubUserName,
                          string.IsNullOrEmpty(InstalledComponents.ControlPanelVersion) ? string.Empty : "-u");

            InstalledComponents.ControlPanelVersion = InstallationComponents.ControlPanelVersion;
            CacheHelper.SetInstalledComponents(UserId, InstalledComponents);
        }

        private string RunScript(InstallationProgressStep? progressStep, FileMap runServerScript, params string[] scriptParams)
        {
            return RunScript(progressStep, runServerScript, true, scriptParams);
        }
        
        private string RunScript(InstallationProgressStep? progressStep, FileMap runServerScript, bool useSudo, params string[] scriptParams)
        {
            if (progressStep.HasValue)
            {
                InstallationProgress.Step = progressStep.Value;
                CacheHelper.SetInstallationProgress(UserId, InstallationProgress);
            }

            var commandFormat = (useSudo ? "sudo " : string.Empty) + "bash {0} {1}";

            using (var stream = SshClient.CreateShellStream("terminal", 300, 100, 800, 600, 1024))
            {
                stream.WriteLine(string.Format(commandFormat, runServerScript.RemotePath, String.Join(" ", scriptParams)));

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationErrorPattern))
                    throw new Exception(output);

                if (output.Contains(Settings.InstallationSuccessPattern))
                    InstallationProgress.ProgressText += output;

                return output;
            }
        }

        private void WarmUp()
        {
            InstallationProgress.Step = InstallationProgressStep.WarmUp;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            SshHelper.WarmingUp(ConnectionInfo.Host);
        }

        private void ChangeScriptFile(SshClient sshClient, params FileMap[] files)
        {
            foreach (var file in files)
            {
                if (!file.IsScriptFile) continue;

                RunCommand(sshClient, string.Format("chmod +x {0}", file.RemotePath));
                RunCommand(sshClient, string.Format("sed -i 's/\r$//' {0}", file.RemotePath));
            }
        }

        private void RunCommand(SshClient sshClient, string command)
        {
            using (var sshCommand = sshClient.CreateCommand(command))
            {
                sshCommand.Execute();

                if (!string.IsNullOrEmpty(sshCommand.Result))
                    InstallationProgress.ProgressText += sshCommand.Result;

                if (!string.IsNullOrEmpty(sshCommand.Error) && sshCommand.ExitStatus != 0)
                    throw new Exception(sshCommand.Error);
            }
        }

        private static string GetTerminalParam(string output, string paramName)
        {
            var res = string.Empty;

            var pattern = string.Format(@"{0}: \[.*?\]", paramName);
            var patternValue = Regex.Match(output, pattern).Value;

            if (!string.IsNullOrEmpty(patternValue))
            {
                res = patternValue.Replace(paramName + ": [", "").TrimEnd(']');
            }

            return res;
        }

        public void Dispose()
        {
            if (_sshClient != null)
            {
                _sshClient.Disconnect();
                _sshClient.Dispose();
                _sshClient = null;
            }

            if (_sftpClient != null)
            {
                _sftpClient.Disconnect();
                _sftpClient.Dispose();
                _sftpClient = null;
            }
        }

        private class FileMap
        {
            public static readonly FileMap RunDockerScript = MakeSetupFileMap("run-docker.sh", "assets");

            public static readonly FileMap CheckBindingsScript = MakeSetupFileMap("check-bindings.sh", "tools");
            public static readonly FileMap CheckPortsScript = MakeSetupFileMap("check-ports.sh", "tools");
            public static readonly FileMap CheckPreviousVersionScript = MakeSetupFileMap("check-previous-version.sh", "tools");
            public static readonly FileMap GetAvailableVersionScript = MakeSetupFileMap("get-available-version.sh", "tools");
            public static readonly FileMap GetOsInfoScript = MakeSetupFileMap("get-os-info.sh", "tools");
            public static readonly FileMap LoginDockerScript = MakeSetupFileMap("login-docker.sh", "tools");
            public static readonly FileMap MakeDirScript = MakeSetupFileMap("make-dir.sh", "tools");
            public static readonly FileMap MakeNetworkScript = MakeSetupFileMap("make-network.sh", "tools");
            public static readonly FileMap MakeSwapScript = MakeSetupFileMap("make-swap.sh", "tools");
            public static readonly FileMap PullImageScript = MakeSetupFileMap("pull-image.sh", "tools");
            public static readonly FileMap RemoveContainerScript = MakeSetupFileMap("remove-container.sh", "tools");

            public static readonly FileMap RunCommunityServerScript = MakeSetupFileMap("run-community-server.sh");
            public static readonly FileMap RunControlPanelScript = MakeSetupFileMap("run-control-panel.sh");
            public static readonly FileMap RunDocumentServerScript = MakeSetupFileMap("run-document-server.sh");
            public static readonly FileMap RunMailServerScript = MakeSetupFileMap("run-mail-server.sh");

            public string LocalPath { get; private set; }
            public string RemoteDir { get; private set; }
            public string FileName { get { return Path.GetFileName(LocalPath); } }
            public string RemotePath { get { return Path.Combine(RemoteDir, FileName).Replace("\\", "/"); } }
            public bool IsScriptFile { get; private set; }

            public FileMap(string localPath, string remoteDir, bool isScriptFile = true)
            {
                LocalPath = HttpContext.Current.Server.MapPath(localPath);
                RemoteDir = remoteDir.TrimEnd('/').Replace("\\", "/");
                IsScriptFile = isScriptFile;
            }

            private static FileMap MakeSetupFileMap(string script, string subFolder = "")
            {
                return new FileMap(Path.Combine("~/Executables", subFolder, script), Path.Combine(Settings.RemoteServerDir, "setup", subFolder));
            }

            public static FileMap MakeLicenseFileMap(string fileName, string moduleName)
            {
                return new FileMap(FileHelper.GetTmpFileVirtualPath(fileName), Path.Combine(Settings.RemoteServerDir, moduleName, "data"), false);
            }
        }
    }
}