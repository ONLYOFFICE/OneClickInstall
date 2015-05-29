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
using System.ComponentModel;
using System.Web.Configuration;
using OneClickInstallation.Classes;
using log4net;

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

        public static string SupportEmail
        {
            get { return GetAppSettings("supportEmail", string.Empty); }
        }

        public static string SourceUrl
        {
            get { return GetAppSettings("sourceUrl", string.Empty); }
        }

        public static EmailSender EmailSender
        {
            get
            {
                try
                {
                    var settings = GetAppSettings("emailSender", string.Empty).Split('|');

                    return new EmailSender
                        {
                            Host = settings[0],
                            Port = Convert.ToInt32(settings[1]),
                            Email = settings[2],
                            Password = settings[3],
                            EnableSsl = Convert.ToBoolean(settings[4])
                        };
                }
                catch (Exception ex)
                {
                    LogManager.GetLogger("ASC").Error(ex.Message, ex);

                    return null;
                }
            }
        }

        public const string RemoteServerDir = "/app/onlyoffice";

        public const string InstallationStopPattern = "INSTALLATION-STOP";
        public const string InstallationRebootPattern = "INSTALLATION-STOP-REBOOT";
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