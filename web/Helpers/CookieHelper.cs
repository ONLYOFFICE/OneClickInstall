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
using System.Web.Security;

namespace OneClickInstallation.Helpers
{
    public class CookieHelper
    {
        private const string CookieKey = "ociuserid";

        public static string GetCookie()
        {
            var cookie = HttpContext.Current.Request.Cookies[CookieKey];

            if (cookie != null && !string.IsNullOrEmpty(cookie.Value))
            {
                var ticket = FormsAuthentication.Decrypt(cookie.Value);

                if (ticket == null || ticket.Expired) return null;

                return ticket.UserData;
            }

            return null;
        }

        public static void SetCookie(string value)
        {
            var now = DateTime.Now;

            var ticket = new FormsAuthenticationTicket(1, CookieKey, now, now.AddDays(1), true, value);

            var ticketKey = FormsAuthentication.Encrypt(ticket);

            var cookie = new HttpCookie(CookieKey, ticketKey)
            {
                Expires = now.AddDays(1),
                HttpOnly = true
            };

            HttpContext.Current.Response.Cookies.Add(cookie);
        }

        public static void ClearCookie()
        {
            var now = DateTime.Now;

            var cookie = new HttpCookie(CookieKey, null)
            {
                Expires = now.AddDays(-1)
            };

            HttpContext.Current.Response.Cookies.Add(cookie);
        }
    }
}