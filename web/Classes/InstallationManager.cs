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
        private ConnectionInfo ConnectionInfo { get; set; }
        private InstallationProgressModel InstallationProgress { get; set; }
        private InstallationComponentsModel InstallationComponents { get; set; }

        private SshClient _sshClient;
        private SftpClient _sftpClient;

        private SshClient SshClient
        {
            get
            {
                if (_sshClient == null)
                    _sshClient = new SshClient(ConnectionInfo);

                _sshClient.Connect();
                _sshClient.KeepAliveInterval = TimeSpan.FromMinutes(30);
                _sshClient.SendKeepAlive();

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
                _sftpClient.SendKeepAlive();

                return _sftpClient;
            }
        }

        public InstallationManager(string userId, ConnectionSettingsModel connectionSettings, InstallationComponentsModel installationComponents = null)
        {
            UserId = userId;
            ConnectionInfo = GetConnectionInfo(userId, connectionSettings);
            InstallationProgress = CacheHelper.GetInstallationProgress(userId) ?? new InstallationProgressModel();
            InstallationComponents = installationComponents;
        }

        public void StartInstallation()
        {
            try
            {
                if (InstallationComponents.IsEmpty) return;

                UploadFiles();

                var osInfo = GetOsInfo(FileMap.GetOsInfoScript);

                CheckPorts();

                InstallDocker(osInfo);

                if (InstallationComponents.DocumentServer)
                    InstallDocumentServer();

                if (InstallationComponents.MailServer)
                    InstallMailServer();

                if (InstallationComponents.CommunityServer)
                    InstallCommunityServer();

                CheckPreviousVersion(FileMap.CheckPreviousVersionScript);

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

        public InstallationComponentsModel Connect()
        {
            var tmpCheckPreviousVersionScript = new FileMap("~/Executables/tools/check-previous-version.sh", "./");

            UploadFile(tmpCheckPreviousVersionScript);

            CheckPreviousVersion(tmpCheckPreviousVersionScript);

            SftpClient.DeleteFile(tmpCheckPreviousVersionScript.RemotePath);

            return CacheHelper.GetInstalledComponents(UserId);
        }

        private static ConnectionInfo GetConnectionInfo(string userId, ConnectionSettingsModel connectionSettings)
        {
            var authenticationMethods = new List<AuthenticationMethod>();

            if (!string.IsNullOrEmpty(connectionSettings.Password))
            {
                authenticationMethods.Add(new PasswordAuthenticationMethod(connectionSettings.UserName, connectionSettings.Password));
            }

            if (!string.IsNullOrEmpty(connectionSettings.SshKey))
            {
                var keyFiles = new[] { new PrivateKeyFile(FileHelper.GetFile(userId, connectionSettings.SshKey)) };
                authenticationMethods.Add(new PrivateKeyAuthenticationMethod(connectionSettings.UserName, keyFiles));
            }

            return new ConnectionInfo(connectionSettings.Host, connectionSettings.UserName, authenticationMethods.ToArray());
        }

        private void UploadFiles()
        {
            InstallationProgress.Step = InstallationProgressStep.UploadFiles;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            CreateDirectories();

            UploadFile(FileMap.GetOsInfoScript,
                       FileMap.CheckPortsScript,
                       FileMap.CheckPreviousVersionScript,
                       FileMap.MakeDirScript,
                       FileMap.RunDockerScript,
                       FileMap.RunCommunityServerScript,
                       FileMap.RunDocumentServerScript,
                       FileMap.RunMailServerScript);
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
                    SftpClient.UploadFile(fileStream, file.FileName, true);
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

        private OsInfo GetOsInfo(FileMap script)
        {
            InstallationProgress.Step = InstallationProgressStep.GetOsInfo;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(string.Format("sudo bash {0}", script.RemotePath));

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationSuccessPattern))
                    InstallationProgress.ProgressText += output;

                if (output.Contains(Settings.InstallationErrorPattern))
                    throw new Exception(output);
            }

            var osInfo = new OsInfo
                                {
                                    Dist = GetTerminalParam(InstallationProgress.ProgressText, "DIST"),
                                    Ver = GetTerminalParam(InstallationProgress.ProgressText, "REV"),
                                    Type = GetTerminalParam(InstallationProgress.ProgressText, "MACH"),
                                    Kernel = GetTerminalParam(InstallationProgress.ProgressText, "KERNEL")
                                };

            return osInfo;
        }

        private void CheckPorts()
        {
            InstallationProgress.Step = InstallationProgressStep.CheckPorts;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(string.Format("sudo bash {0} {1}",
                    FileMap.CheckPortsScript.RemotePath,
                    InstallationComponents.MailServer.ToString().ToLower()));

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationSuccessPattern))
                    InstallationProgress.ProgressText += output;

                if (output.Contains(Settings.InstallationErrorPattern))
                    throw new Exception(output);
            }
        }

        private void MakeDirectories(FileMap script)
        {
            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(string.Format("sudo bash {0} \"{1}\"", script.RemotePath, Settings.RemoteServerDir));

                var output = stream.Expect(Settings.InstallationSuccessPattern);

                InstallationProgress.ProgressText += output;
            }
        }

        private void CheckPreviousVersion(FileMap script)
        {
            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(string.Format("bash {0}", script.RemotePath));

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationSuccessPattern))
                {
                    InstallationComponents = new InstallationComponentsModel
                    {
                        MailServer = !string.IsNullOrEmpty(GetTerminalParam(output, "MAIL_SERVER_ID")),
                        DocumentServer = !string.IsNullOrEmpty(GetTerminalParam(output, "DOCUMENT_SERVER_ID")),
                        CommunityServer = !string.IsNullOrEmpty(GetTerminalParam(output, "COMMUNITY_SERVER_ID"))
                    };

                    InstallationProgress.ProgressText += output;
                }

                if (output.Contains(Settings.InstallationErrorPattern))
                    throw new Exception(output);
            }

            CacheHelper.SetInstalledComponents(UserId, InstallationComponents.IsEmpty ? null : InstallationComponents);
        }

        private void InstallDocker(OsInfo osInfo, bool afterReboot = false)
        {
            if(afterReboot)
                CheckPorts();

            var needReboot = false;

            InstallationProgress.Step = InstallationProgressStep.InstallDocker;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            var command = string.Format("sudo bash {0} \"{1}\" \"{2}\" \"{3}\" \"{4}\" {5}",
                                        FileMap.RunDockerScript.RemotePath,
                                        osInfo.Dist,
                                        osInfo.Ver,
                                        osInfo.Type,
                                        osInfo.Kernel,
                                        afterReboot ? true.ToString().ToLower() : string.Empty);

            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(command);

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationRebootPattern))
                {
                    InstallationProgress.ProgressText += output;
                    InstallationProgress.Step = InstallationProgressStep.RebootServer;
                    CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

                    needReboot = true;

                    stream.WriteLine("sudo reboot");

                    System.Threading.Thread.Sleep(10000);
                }
                else
                {
                    if (output.Contains(Settings.InstallationSuccessPattern))
                        InstallationProgress.ProgressText += output;

                    if (output.Contains(Settings.InstallationErrorPattern))
                        throw new Exception(output);
                }
            }

            if (needReboot)
            {
                InstallDocker(osInfo, true);
            }
        }

        private void InstallCommunityServer()
        {
            InstallServer(InstallationProgressStep.InstallCommunityServer, FileMap.RunCommunityServerScript);
        }

        private void InstallDocumentServer()
        {
            InstallServer(InstallationProgressStep.InstallDocumentServer, FileMap.RunDocumentServerScript);
        }

        private void InstallMailServer()
        {
            InstallServer(InstallationProgressStep.InstallMailServer, FileMap.RunMailServerScript, InstallationComponents.MailDomain);
        }

        private void InstallServer(InstallationProgressStep progressStep, FileMap runServerScript, string serverScriptParam = "")
        {
            InstallationProgress.Step = progressStep;
            CacheHelper.SetInstallationProgress(UserId, InstallationProgress);

            using (var stream = SshClient.CreateShellStream("terminal", 150, 24, 800, 600, 1024))
            {
                stream.WriteLine(!string.IsNullOrEmpty(serverScriptParam)
                                     ? string.Format("sudo bash {0} \"{1}\"", runServerScript.RemotePath, serverScriptParam)
                                     : string.Format("sudo bash {0}", runServerScript.RemotePath));

                var output = stream.Expect(Settings.InstallationStopPattern);

                if (output.Contains(Settings.InstallationSuccessPattern))
                    InstallationProgress.ProgressText += output;

                if (output.Contains(Settings.InstallationErrorPattern))
                    throw new Exception(output);
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
            public static readonly FileMap GetOsInfoScript = MakeSetupFileMap("get-os-info.sh", "tools");
            public static readonly FileMap CheckPortsScript = MakeSetupFileMap("check-ports.sh", "tools");
            public static readonly FileMap CheckPreviousVersionScript = MakeSetupFileMap("check-previous-version.sh", "tools");
            public static readonly FileMap MakeDirScript = MakeSetupFileMap("make-dir.sh", "tools");
            public static readonly FileMap RunDockerScript = MakeSetupFileMap("run-docker.sh", "assets");
            public static readonly FileMap RunCommunityServerScript = MakeSetupFileMap("run-community-server.sh");
            public static readonly FileMap RunDocumentServerScript = MakeSetupFileMap("run-document-server.sh");
            public static readonly FileMap RunMailServerScript = MakeSetupFileMap("run-mail-server.sh");

            public string LocalPath { get; private set; }
            public string RemoteDir { get; private set; }
            public string FileName { get { return Path.GetFileName(LocalPath); } }
            public string RemotePath { get { return Path.Combine(RemoteDir, FileName).Replace("\\", "/"); } }

            public FileMap(string localPath, string remoteDir)
            {
                LocalPath = HttpContext.Current.Server.MapPath(localPath);
                RemoteDir = remoteDir.TrimEnd('/').Replace("\\", "/");
            }

            private static FileMap MakeSetupFileMap(string script, string subFolder = "")
            {
                return new FileMap(Path.Combine("~/Executables", subFolder, script), Path.Combine(Settings.RemoteServerDir, "setup", subFolder));
            }
        }
    }
}