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

COMMUNITY_SERVER_VERSION='';
DOCUMENT_SERVER_VERSION='';
MAIL_SERVER_VERSION='';
CONTROL_PANEL_VERSION='';
LICENSE_FILE_EXIST="false";

COMMUNITY_CONTAINER_NAME='onlyoffice-community-server';
DOCUMENT_CONTAINER_NAME='onlyoffice-document-server';
MAIL_CONTAINER_NAME='onlyoffice-mail-server';
CONTROLPANEL_CONTAINER_NAME='onlyoffice-control-panel';

while [ "$1" != "" ]; do
	case $1 in

		-cc | --communitycontainer )
			if [ "$2" != "" ]; then
				COMMUNITY_CONTAINER_NAME=$2
				shift
			fi
		;;

		-dc | --documentcontainer )
			if [ "$2" != "" ]; then
				DOCUMENT_CONTAINER_NAME=$2
				shift
			fi
		;;

		-mc | --mailcontainer )
			if [ "$2" != "" ]; then
				MAIL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-cpc | --controlpanelcontainer )
			if [ "$2" != "" ]; then
				CONTROLPANEL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -cc, --communitycontainer          community container name"
			echo "      -dc, --documentcontainer          document container name"
			echo "      -mc, --mailcontainer          mail container name"
			echo "      -cpc, --controlpanelcontainer          controlpanel container name"
			echo "      -?, -h, --help        this help"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 1
		;;
	esac
	shift
done

root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		echo "INSTALLATION-STOP-ERROR[8]"
		exit 0;
	fi
}

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

check_license_file_in_dir () {
	if [ "LICENSE_FILE_EXIST" != "true" ]; then
		if [ -d "$1" ]; then
			for file in "$1"/*.lic
			do
				if [ -f "${file}" ]; then
					LICENSE_FILE_EXIST="true";
					break
				fi
			done
		fi
	fi
}

check_license_file () {
	check_license_file_in_dir "/app/onlyoffice/DocumentServer/data"
	check_license_file_in_dir "/app/onlyoffice/DocumentServer/data"
	check_license_file_in_dir "/app/onlyoffice/MailServer/data"
	check_license_file_in_dir "/app/onlyoffice/ControlPanel/data"
}

root_checking

if ! command_exists sudo ; then
	install_sudo;
fi


if command_exists docker ; then
    MAIL_SERVER_VERSION=$(sudo docker ps -a | grep ${MAIL_CONTAINER_NAME} | awk '{print $2}' | sed 's/.*://');
    DOCUMENT_SERVER_VERSION=$(sudo docker ps -a | grep ${DOCUMENT_CONTAINER_NAME} | awk '{print $2}' | sed 's/.*://');
    COMMUNITY_SERVER_VERSION=$(sudo docker ps -a | grep ${COMMUNITY_CONTAINER_NAME} | awk '{print $2}' | sed 's/.*://');
    CONTROL_PANEL_VERSION=$(sudo docker ps -a | grep ${CONTROLPANEL_CONTAINER_NAME} | awk '{print $2}' | sed 's/.*://');
fi

check_license_file

echo "MAIL_SERVER_VERSION: [$MAIL_SERVER_VERSION]"
echo "DOCUMENT_SERVER_VERSION: [$DOCUMENT_SERVER_VERSION]"
echo "COMMUNITY_SERVER_VERSION: [$COMMUNITY_SERVER_VERSION]"
echo "CONTROL_PANEL_VERSION: [$CONTROL_PANEL_VERSION]"
echo "LICENSE_FILE_EXIST: [$LICENSE_FILE_EXIST]"


echo "INSTALLATION-STOP-SUCCESS"