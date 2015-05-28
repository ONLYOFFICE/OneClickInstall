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

if [[ -n ${MAIL_SERVER_ID} ]]; then
    echo "ONLYOFFICE MAIL SERVER is already installed."

    sudo docker start ${MAIL_SERVER_ID};

    echo "INSTALLATION-STOP-SUCCESS"
    exit 0;
fi

MAIL_SERVER_HOSTNAME=${1};

if [[ -z ${MAIL_SERVER_HOSTNAME} ]]; then
	echo "Please, set hostname for mail server"
	echo "INSTALLATION-STOP-ERROR[4]"

	exit 0;
fi

sudo docker run --restart=always --privileged -i -t -d --name onlyoffice-mail-server -p 25:25 -p 143:143 -p 587:587 \
-v /app/onlyoffice/MailServer/data:/var/vmail \
-v /app/onlyoffice/MailServer/data/certs:/etc/pki/tls/mailserver \
-v /app/onlyoffice/MailServer/logs:/var/log -v \
/app/onlyoffice/MailServer/mysql:/var/lib/mysql -h ${MAIL_SERVER_HOSTNAME} onlyoffice/mailserver

echo "INSTALLATION-STOP-SUCCESS"
