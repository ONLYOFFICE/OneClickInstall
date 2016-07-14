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
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using Newtonsoft.Json;
using OneClickInstallation.Classes;
using OneClickInstallation.Models;
using log4net;

namespace OneClickInstallation.Helpers
{
    public class TagHelper
    {
        public static InstallationComponentsModel InitializeAvailableTags(bool enterprise)
        {
            var token = GetAuthToken();

            var available = new InstallationComponentsModel
                {
                    CommunityServerVersion = GetLatestTagName(GetImageTags(enterprise ? Settings.DockerEnterpriseCommunityImageName : Settings.DockerCommunityImageName, token)),
                    DocumentServerVersion = GetLatestTagName(GetImageTags(enterprise ? Settings.DockerEnterpriseDocumentImageName : Settings.DockerDocumentImageName, token)),
                    MailServerVersion = GetLatestTagName(GetImageTags(enterprise ? Settings.DockerEnterpriseMailImageName : Settings.DockerMailImageName, token)),
                    ControlPanelVersion = GetLatestTagName(GetImageTags(enterprise ? Settings.DockerEnterpriseControlPanelImageName : Settings.DockerControlPanelImageName, token)),
                };

            CacheHelper.SetAvailableComponents(enterprise, available);

            return available;
        }

        private static List<ImageTag> GetImageTags(string imageName, string token)
        {
            if (string.IsNullOrEmpty(imageName))
                throw new ArgumentNullException("imageName");

            try
            {
                var req = System.Net.WebRequest.Create(string.Format(Settings.DockerHubTagsUrlFormat, imageName));

                req.Method = "GET";

                if(!string.IsNullOrEmpty(token))
                    req.Headers.Add("Authorization", "JWT " + token);

                string output;

                using (var resp = req.GetResponse())
                {
                    using (var stream = resp.GetResponseStream())
                    {
                        if (stream == null) return null;

                        var sr = new StreamReader(stream);
                        output = sr.ReadToEnd();
                        sr.Close();
                    }
                }

                if (string.IsNullOrEmpty(output))
                    return null;

                var obj = JsonConvert.DeserializeObject<dynamic>(output);

                return ((IEnumerable<dynamic>) obj.results).Select(x => new ImageTag {Name = x.name}).ToList();
            }
            catch (Exception ex)
            {
                LogManager.GetLogger("ASC").Error(ex.Message, ex);
                return null;
            }
        }

        private static string GetAuthToken()
        {
            if (string.IsNullOrEmpty(Settings.DockerHubUserName) || string.IsNullOrEmpty(Settings.DockerHubPassword))
                return null;
            
            var req = System.Net.WebRequest.Create(Settings.DockerHubLoginUrl);

            req.Method = "POST";
            req.ContentType = "application/json";

            var credentials = JsonConvert.SerializeObject(new
                {
                    username = Settings.DockerHubUserName,
                    password = Settings.DockerHubPassword
                });

            var data = Encoding.ASCII.GetBytes(credentials);

            req.ContentLength = data.Length;

            using (var stream = req.GetRequestStream())
            {
                stream.Write(data, 0, data.Length);
            }

            string output;

            using (var resp = req.GetResponse())
            {
                using (var stream = resp.GetResponseStream())
                {
                    if (stream == null) return null;

                    var sr = new StreamReader(stream);
                    output = sr.ReadToEnd();
                    sr.Close();
                }
            }

            if (string.IsNullOrEmpty(output))
                return null;

            var obj = JsonConvert.DeserializeObject<dynamic>(output);

            return obj.token; 
        }

        private static string GetLatestTagName(List<ImageTag> imageTags)
        {
            if (imageTags == null || imageTags.Count == 0)
                return null;

            Version latest = null;
            var unparsed = new List<string>();

            foreach (var imageTag in imageTags)
            {
                Version current;
                if (Version.TryParse(imageTag.Name, out current))
                {
                    if (latest == null || current > latest)
                        latest = current;
                }
                else
                {
                    unparsed.Add(imageTag.Name);
                }
            }

            if (latest != null) return latest.ToString();

            if (unparsed.Any())
            {
                return unparsed.Contains("latest") ? "latest" : unparsed.First();
            }

            return null;
        }
    }
}