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
    public class InstallationComponentsModel
    {
        public string CommunityServerVersion { get; set; }
        public string DocumentServerVersion { get; set; }
        public string MailServerVersion { get; set; }
        public string MailDomain { get; set; }
        public string ControlPanelVersion { get; set; }
        public bool LicenseFileExist { get; set; }

        public bool IsEmpty
        {
            get
            {
                return string.IsNullOrEmpty(CommunityServerVersion) &&
                       string.IsNullOrEmpty(DocumentServerVersion) &&
                       string.IsNullOrEmpty(MailServerVersion) &&
                       string.IsNullOrEmpty(ControlPanelVersion);
            }
        }

        public bool IsFull
        {
            get
            {
                return !string.IsNullOrEmpty(CommunityServerVersion) &&
                       !string.IsNullOrEmpty(DocumentServerVersion) &&
                       !string.IsNullOrEmpty(MailServerVersion) &&
                       !string.IsNullOrEmpty(ControlPanelVersion);
            }
        }
    }
}