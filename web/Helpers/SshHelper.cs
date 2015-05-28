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
using System.IO;
using System.Threading;
using System.Web;
using OneClickInstallation.Classes;
using OneClickInstallation.Models;

namespace OneClickInstallation.Helpers
{
    public class SshHelper
    {
        public static void StartInstallation(string userId, ConnectionSettingsModel connectionSettings, InstallationComponentsModel installationComponents)
        {
            ThreadPool.QueueUserWorkItem(delegate(object state)
            {
                var workerState = state as WorkerState;

                if (workerState == null) return;

                HttpContext.Current = workerState.Context;

                using (var installationManager = new InstallationManager(workerState.UserId, workerState.ConnectionSettings, workerState.InstallationComponents))
                {
                    installationManager.StartInstallation();
                }
            }, new WorkerState
            {
                Context = HttpContext.Current,
                ConnectionSettings = connectionSettings,
                InstallationComponents = installationComponents,
                UserId = userId
            });

        }

        public static InstallationComponentsModel Connect(string userId, ConnectionSettingsModel connectionSettings)
        {
            using (var installationManager = new InstallationManager(userId, connectionSettings))
            {
                return installationManager.Connect();
            }
        }

        public static void WarmingUp(string host)
        {
            var exitTime = DateTime.Now.AddMinutes(3);

            var uriString = host.StartsWith("http") ? host : "http://" + host;

            while (true)
            {
                if (DateTime.Now > exitTime)
                    break;
                
                try
                {
                    var req = System.Net.WebRequest.Create(uriString);

                    req.Method = "GET";

                    using (var resp = req.GetResponse())
                    {
                        using (var stream = resp.GetResponseStream())
                        {
                            if (stream == null) return;

                            var sr = new StreamReader(stream);
                            var output = sr.ReadToEnd();

                            if (!string.IsNullOrEmpty(output))
                                break;

                            sr.Close();
                        }
                    }
                }
                catch (Exception)
                {
                }

                Thread.Sleep(1000);
            }
        }

        private class WorkerState
        {
            public HttpContext Context { get; set; }
            public ConnectionSettingsModel ConnectionSettings { get; set; }
            public InstallationComponentsModel InstallationComponents { get; set; }
            public string UserId { get; set; }
        }
    }
}