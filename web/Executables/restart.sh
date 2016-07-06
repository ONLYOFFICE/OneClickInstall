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

COMMUNITY_CONTAINER_NAME="onlyoffice-community-server";
DOCUMENT_CONTAINER_NAME="onlyoffice-document-server";
MAIL_CONTAINER_NAME="onlyoffice-mail-server";
CONTROLPANEL_CONTAINER_NAME="onlyoffice-control-panel";
FAST="false"

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

		-f | --fast )
			if [ "$2" != "" ]; then
				FAST=$2
				shift
			fi
		;;

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -cc, --communitycontainer         community container name"
			echo "      -dc, --documentcontainer          document container name"
			echo "      -mc, --mailcontainer              mail container name"
			echo "      -cpc, --controlpanelcontainer     control panel container name"
			echo "      -f, --fast     				  	  fast restart services in community container"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 0
		;;
	esac
	shift
done



root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 0;
	fi
}

command_exists () {
    type "$1" &> /dev/null;
}

install_sudo () {
	if command_exists apt-get; then
		apt-get install sudo
	elif command_exists yum; then
		yum install sudo
	fi

	if ! command_exists sudo; then
		echo "command sudo not found"
		exit 0;
	fi
}

fast_restart () {
	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		sudo docker exec ${COMMUNITY_CONTAINER_NAME} service monoserve restart;
		sudo docker exec ${COMMUNITY_CONTAINER_NAME} service monoserve2 restart;
		sudo docker exec ${COMMUNITY_CONTAINER_NAME} service nginx restart;
	else
		echo "COMMUNITY SERVER not found"
	fi
}

restart_document_server () {
	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});

	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		if [[ -z "$1" ]]; then
			sudo docker restart ${DOCUMENT_SERVER_ID};
		else
			sudo docker $1 ${DOCUMENT_SERVER_ID};
		fi
	else
		echo "DOCUMENT SERVER not found"
	fi
}

restart_mail_server () {
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

	if [[ -n ${MAIL_SERVER_ID} ]]; then
		if [[ -z "$1" ]]; then
			sudo docker restart ${MAIL_SERVER_ID};
		else
			sudo docker $1 ${MAIL_SERVER_ID};
		fi
	else
		echo "MAIL SERVER not found"
	fi
}

restart_controlpanel () {
	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		if [[ -z "$1" ]]; then
			sudo docker restart ${CONTROL_PANEL_ID};
		else
			sudo docker $1 ${CONTROL_PANEL_ID};
		fi
	else
		echo "CONTROL PANEL not found"
	fi
}

restart_community_server () {
	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		if [[ -z "$1" ]]; then
			sudo docker restart ${COMMUNITY_SERVER_ID};
		else
			sudo docker $1 ${COMMUNITY_SERVER_ID};
		fi
	else
		echo "COMMUNITY SERVER not found"
	fi
}

start_restart () {
	root_checking

	if ! command_exists sudo ; then
		install_sudo;
	fi

	if [ "$FAST" == "true" ]; then
		fast_restart
	else
		restart_document_server "stop"
		restart_mail_server "stop"
		restart_controlpanel "stop"
		restart_community_server "stop"

		restart_document_server "start"
		restart_mail_server "start"
		restart_controlpanel "start"
		restart_community_server "start"
	fi

	echo "restart complete"
	exit 0;
}


start_restart