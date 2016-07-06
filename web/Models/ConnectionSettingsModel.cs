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

namespace OneClickInstallation.Models
{
    public class ConnectionSettingsModel
    {
        public string Host { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string SshKey { get; set; }
        public string LicenseKey { get; set; }
        public bool Enterprise { get; set; }
    }
}