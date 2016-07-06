#!/bin/bash

# (c) Copyright Ascensio System Limited 2010-2015
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# You can contact Ascensio System SIA by email at sales@onlyoffice.com

sudo mkdir -p "/app/onlyoffice/setup";

sudo mkdir -p "/app/onlyoffice/DocumentServer/data";
sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/FileConverterService";
sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/CoAuthoringService";
sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/DocService";
sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/SpellCheckerService";
sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/LibreOfficeService";

sudo mkdir -p "/app/onlyoffice/MailServer/data/certs";
sudo mkdir -p "/app/onlyoffice/MailServer/logs";
sudo mkdir -p "/app/onlyoffice/MailServer/mysql";

sudo mkdir -p "/app/onlyoffice/CommunityServer/data";
sudo mkdir -p "/app/onlyoffice/CommunityServer/logs";
sudo mkdir -p "/app/onlyoffice/CommunityServer/mysql";

sudo mkdir -p "/app/onlyoffice/ControlPanel/data";
sudo mkdir -p "/app/onlyoffice/ControlPanel/logs";
sudo mkdir -p "/app/onlyoffice/ControlPanel/mysql";

sudo chmod 777 /app -R

echo "INSTALLATION-STOP-SUCCESS"