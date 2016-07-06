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

using System.ComponentModel;
using System.Web.Configuration;

namespace OneClickInstallation.Helpers
{
    public class Settings
    {
        public static bool DebugMode
        {
            get
            {
                #if DEBUG
                return true;
                #else
                return false;
                #endif
            }
        }
        

        public static string Languages
        {
            get { return GetAppSettings("languages", "en,de,fr,es,ru,lv,it"); }
        }

        public static bool ResourcesFromDataBase
        {
            get { return GetAppSettings("resources.from-db", true); }
        }

        public static int MaxFileSize
        {
            get { return GetAppSettings("maxFileSize", 1048576); }
        }
        

        public static string AnalyticsFileUrl
        {
            get { return GetAppSettings("analyticsFileUrl", string.Empty); }
        }

        public static string TermsFileUrl
        {
            get { return GetAppSettings("termsFileUrl", string.Empty); }
        }

        public static string SourceUrl
        {
            get { return GetAppSettings("sourceUrl", string.Empty); }
        }

        public static string DevUrl
        {
            get { return GetAppSettings("devUrl", string.Empty); }
        }

        public static string HelpUrl
        {
            get { return GetAppSettings("helpUrl", string.Empty); }
        }

        public static string LicenseUrl
        {
            get { return GetAppSettings("licenseUrl", string.Empty); }
        }


        public static string DockerCommunityContainerName
        {
            get { return GetAppSettings("docker.community-container-name", "onlyoffice-community-server"); }
        }

        public static string DockerDocumentContainerName
        {
            get { return GetAppSettings("docker.document-container-name", "onlyoffice-document-server"); }
        }

        public static string DockerMailContainerName
        {
            get { return GetAppSettings("docker.mail-container-name", "onlyoffice-mail-server"); }
        }

        public static string DockerControlPanelContainerName
        {
            get { return GetAppSettings("docker.controlpanel-container-name", "onlyoffice-control-panel"); }
        }


        public static string DockerCommunityImageName
        {
            get { return GetAppSettings("docker.community-image-name", "onlyoffice/communityserver"); }
        }

        public static string DockerDocumentImageName
        {
            get { return GetAppSettings("docker.document-image-name", "onlyoffice/documentserver"); }
        }

        public static string DockerMailImageName
        {
            get { return GetAppSettings("docker.mail-image-name", "onlyoffice/mailserver"); }
        }

        public static string DockerControlPanelImageName
        {
            get { return GetAppSettings("docker.controlpanel-image-name", "onlyoffice/controlpanel"); }
        }


        public static string DockerEnterpriseCommunityImageName
        {
            get { return GetAppSettings("docker.enterprise.community-image-name", "onlyoffice4enterprise/communityserver-ee"); }
        }

        public static string DockerEnterpriseDocumentImageName
        {
            get { return GetAppSettings("docker.enterprise.document-image-name", "onlyoffice4enterprise/documentserver-ee"); }
        }

        public static string DockerEnterpriseMailImageName
        {
            get { return GetAppSettings("docker.enterprise.mail-image-name", "onlyoffice/mailserver"); }
        }

        public static string DockerEnterpriseControlPanelImageName
        {
            get { return GetAppSettings("docker.enterprise.controlpanel-image-name", "onlyoffice4enterprise/controlpanel-ee"); }
        }


        public static string DockerHubLoginUrl
        {
            get { return GetAppSettings("dockerhub.loginUrl", "https://hub.docker.com/v2/users/login/"); }
        }

        public static string DockerHubTagsUrlFormat
        {
            get { return GetAppSettings("dockerhub.tagsUrlFormat", "https://hub.docker.com/v2/repositories/{0}/tags/"); }
        }

        public static string DockerHubUserName
        {
            get { return GetAppSettings("dockerhub.userName", string.Empty); }
        }

        public static string DockerHubPassword
        {
            get { return GetAppSettings("dockerhub.password", string.Empty); }
        }


        public static string CacheKey
        {
            get { return GetAppSettings("cacheKey", string.Empty); }
        }


        public const string RemoteServerDir = "/app/onlyoffice";

        public const string TrialFileName = "trial.lic";

        public const string InstallationStopPattern = "INSTALLATION-STOP";
        public const string InstallationSuccessPattern = "INSTALLATION-STOP-SUCCESS";
        public const string InstallationErrorPattern = "INSTALLATION-STOP-ERROR";


        private static T GetAppSettings<T>(string key, T defaultValue)
        {
            var configSetting = WebConfigurationManager.AppSettings[key];
            if (!string.IsNullOrEmpty(configSetting))
            {
                var converter = TypeDescriptor.GetConverter(typeof(T));
                if (converter.CanConvertFrom(typeof(string)))
                {
                    return (T)converter.ConvertFromString(configSetting);
                }
            }
            return defaultValue;
        }
    }
}