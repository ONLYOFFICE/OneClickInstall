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
using System.Web;
using System.Web.Caching;
using OneClickInstallation.Classes;
using OneClickInstallation.Models;

namespace OneClickInstallation.Helpers
{
    public static class CacheHelper
    {
        public static ConnectionSettingsModel GetConnectionSettings(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return null;

            var key = "connectionSettings" + userId;
            return CacheGet<ConnectionSettingsModel>(key);
        }

        public static void SetConnectionSettings(string userId, ConnectionSettingsModel value)
        {
            if (string.IsNullOrEmpty(userId)) return;

            var key = "connectionSettings" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static InstallationComponentsModel GetInstalledComponents(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return null;

            var key = "installedComponents" + userId;
            return CacheGet<InstallationComponentsModel>(key);
        }

        public static void SetInstalledComponents(string userId, InstallationComponentsModel value)
        {
            if (string.IsNullOrEmpty(userId)) return;

            var key = "installedComponents" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static InstallationComponentsModel GetSelectedComponents(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return null;

            var key = "selectedComponents" + userId;
            return CacheGet<InstallationComponentsModel>(key);
        }

        public static void SetSelectedComponents(string userId, InstallationComponentsModel value)
        {
            if (string.IsNullOrEmpty(userId)) return;

            var key = "selectedComponents" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static InstallationProgressModel GetInstallationProgress(string userId)
        {
            if (string.IsNullOrEmpty(userId)) return null;

            var key = "installationProgress" + userId;
            return CacheGet<InstallationProgressModel>(key);
        }

        public static void SetInstallationProgress(string userId, InstallationProgressModel value)
        {
            if (string.IsNullOrEmpty(userId)) return;

            var key = "installationProgress" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static OsInfo GetOsInfo(string userId)
        {
            var key = "osInfo" + userId;
            return CacheGet<OsInfo>(key);
        }

        public static void SetOsInfo(string userId, OsInfo value)
        {
            var key = "osInfo" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static RequestInfoModel GetRequestInfo(string userId)
        {
            var key = "requestInfo" + userId;
            return CacheGet<RequestInfoModel>(key);
        }

        public static void SetRequestInfo(string userId, RequestInfoModel value)
        {
            var key = "requestInfo" + userId;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static string GetJsResuorce(string culture)
        {
            if (string.IsNullOrEmpty(culture)) return null;

            var key = "jsResuorce" + culture;
            return CacheGet<string>(key);
        }

        public static void SetJsResuorce(string culture, string value)
        {
            if (string.IsNullOrEmpty(culture)) return;

            var key = "jsResuorce" + culture;
            CacheSet(key, value, TimeSpan.FromDays(1));
        }


        public static InstallationComponentsModel GetAvailableComponents(bool enterprise)
        {
            var res = CacheGet<InstallationComponentsModel>(enterprise ? "availableEnterpriseComponents" : "availableComponents");
            return res ?? TagHelper.InitializeAvailableTags(enterprise);
        }

        public static void SetAvailableComponents(bool enterprise, InstallationComponentsModel value)
        {
            CacheSet(enterprise ? "availableEnterpriseComponents" : "availableComponents", value, TimeSpan.FromDays(1));
        }


        public static void ClearUserCache(string userId)
        {
            SetConnectionSettings(userId, null);
            SetInstalledComponents(userId, null);
            SetSelectedComponents(userId, null);
            SetInstallationProgress(userId, null);
            SetOsInfo(userId, null);
            SetRequestInfo(userId, null);
        }

        public static void ClearCache()
        {
            foreach (var lang in LangHelper.GetLanguages())
            {
                SetJsResuorce(new CultureInfo(lang).TwoLetterISOLanguageName, null);
            }

            SetAvailableComponents(true, null);
            SetAvailableComponents(false, null);
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