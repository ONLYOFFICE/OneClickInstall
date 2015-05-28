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
using System.Web;
using System.Web.Caching;
using OneClickInstallation.Models;

namespace OneClickInstallation.Helpers
{
    public static class CacheHelper
    {
        public static ConnectionSettingsModel GetConnectionSettings(string userId)
        {
            var key = "connectionSettings" + userId;
            return CacheGet<ConnectionSettingsModel>(key);
        }

        public static void SetConnectionSettings(string userId, ConnectionSettingsModel value)
        {
            var key = "connectionSettings" + userId;
            CacheSet(key, value, TimeSpan.FromHours(1));
        }


        public static InstallationComponentsModel GetInstalledComponents(string userId)
        {
            var key = "installedComponents" + userId;
            return CacheGet<InstallationComponentsModel>(key);
        }

        public static void SetInstalledComponents(string userId, InstallationComponentsModel value)
        {
            var key = "installedComponents" + userId;
            CacheSet(key, value, TimeSpan.FromHours(1));
        }


        public static InstallationComponentsModel GetSelectedComponents(string userId)
        {
            var key = "selectedComponents" + userId;
            return CacheGet<InstallationComponentsModel>(key);
        }

        public static void SetSelectedComponents(string userId, InstallationComponentsModel value)
        {
            var key = "selectedComponents" + userId;
            CacheSet(key, value, TimeSpan.FromHours(1));
        }


        public static InstallationProgressModel GetInstallationProgress(string userId)
        {
            var key = "installationProgress" + userId;
            return CacheGet<InstallationProgressModel>(key);
        }

        public static void SetInstallationProgress(string userId, InstallationProgressModel value)
        {
            var key = "installationProgress" + userId;
            CacheSet(key, value, TimeSpan.FromHours(1));
        }


        public static string GetJsResuorce(string culture)
        {
            var key = "jsResuorce" + culture;
            return CacheGet<string>(key);
        }

        public static void SetJsResuorce(string culture, string value)
        {
            var key = "jsResuorce" + culture;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        private static T CacheGet<T>(string key)
        {
            var value = HttpRuntime.Cache.Get(key);
            return (T)value;
        }

        private static void CacheSet<T>(string key, T value, TimeSpan slidingExpiration)
        {
            if (Equals(value, default(T)))
                HttpRuntime.Cache.Remove(key);
            else
                HttpRuntime.Cache.Insert(key, value, null, Cache.NoAbsoluteExpiration, slidingExpiration);
        }
    }
}