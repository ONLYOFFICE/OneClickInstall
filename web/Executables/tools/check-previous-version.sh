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

MAIL_SERVER_ID="";
DOCUMENT_SERVER_ID="";
COMMUNITY_SERVER_ID="";


command_exists () {
    type "$1" &> /dev/null ;
}


install_sudo () {
	if command_exists apt-get ; then
		apt-get install sudo 
	elif command_exists yum ; then
		yum install sudo
	fi

	if command_exists sudo ; then
		echo "sudo successfully installed"
	else
		echo "command sudo not found"
		echo "INSTALLATION-STOP-ERROR[5]"
		exit 0;
	fi
}


if ! command_exists sudo ; then
	install_sudo;
fi


if command_exists docker ; then
    MAIL_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-mail-server' | awk '{print $1}');
    DOCUMENT_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-document-server' | awk '{print $1}');
    COMMUNITY_SERVER_ID=$(sudo docker ps -a | grep 'onlyoffice-community-server' | awk '{print $1}');
fi


echo "MAIL_SERVER_ID: [$MAIL_SERVER_ID]"
echo "DOCUMENT_SERVER_ID: [$DOCUMENT_SERVER_ID]"
echo "COMMUNITY_SERVER_ID: [$COMMUNITY_SERVER_ID]"


echo "INSTALLATION-STOP-SUCCESS"