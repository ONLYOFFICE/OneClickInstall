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

DOCUMENT_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-document-server' | awk '{print $1}');

if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
    echo "ONLYOFFICE DOCUMENT SERVER is already installed."

    sudo docker start ${DOCUMENT_SERVER_ID};

    echo "INSTALLATION-STOP-SUCCESS"
    exit 0;
fi

sudo docker run --restart=always -i -t -d --name onlyoffice-document-server \
-v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data \
-v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice \
onlyoffice/documentserver

echo "INSTALLATION-STOP-SUCCESS"
