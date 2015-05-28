#/bin/bash

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

MAIL_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-mail-server' | awk '{print $1}');
DOCUMENT_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-document-server' | awk '{print $1}');
COMMUNITY_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-community-server' | awk '{print $1}');

if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
    echo "ONLYOFFICE COMMUNITY SERVER is already installed."

    sudo docker start ${COMMUNITY_SERVER_ID};

    echo "INSTALLATION-STOP-SUCCESS"
    exit 0;
fi

RUN_COMMAND="sudo docker run --restart=always --name onlyoffice-community-server -i -t -d -p 80:80 -p 443:443 -p 5222:5222";

if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
	RUN_COMMAND="$RUN_COMMAND  --link onlyoffice-document-server:document_server";
fi

if [[ -n ${MAIL_SERVER_ID} ]]; then
	RUN_COMMAND="$RUN_COMMAND  --link onlyoffice-mail-server:mail_server";
fi	

RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/data:/var/www/onlyoffice/Data -v /app/onlyoffice/CommunityServer/mysql:/var/lib/mysql -v /app/onlyoffice/CommunityServer/logs:/var/log/onlyoffice onlyoffice/communityserver";

${RUN_COMMAND};

echo "INSTALLATION-STOP-SUCCESS"
