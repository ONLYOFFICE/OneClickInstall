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

UPDATE=0
COMMUNITY_PORT=80
COMMUNITY_IMAGE_NAME='onlyoffice/communityserver';
COMMUNITY_CONTAINER_NAME='onlyoffice-community-server';
DOCUMENT_CONTAINER_NAME='onlyoffice-document-server';
MAIL_CONTAINER_NAME='onlyoffice-mail-server';
CONTROLPANEL_CONTAINER_NAME='onlyoffice-control-panel';

while [ "$1" != "" ]; do
	case $1 in

		-u | --update )
			UPDATE=1
		;;

		-i | --image )
			if [ "$2" != "" ]; then
				COMMUNITY_IMAGE_NAME=$2
				shift
			fi
		;;

		-v | --version )
			if [ "$2" != "" ]; then
				VERSION=$2
				shift
			fi
		;;

		-c | --container )
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

		-cc | --controlpanelcontainer )
			if [ "$2" != "" ]; then
				CONTROLPANEL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-p | --password )
			if [ "$2" != "" ]; then
				PASSWORD=$2
				shift
			fi
		;;

		-un | --username )
			if [ "$2" != "" ]; then
				USERNAME=$2
				shift
			fi
		;;

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -u, --update          update"
			echo "      -i, --image          image name"
			echo "      -v, --version          image version"
			echo "      -c, --container          container name"
			echo "      -dc, --documentcontainer          document container name"
			echo "      -mc, --mailcontainer          mail container name"
			echo "      -cc, --controlpanelcontainer          controlpanel container name"
			echo "      -p, --password          dockerhub password"
			echo "      -un, --username          dockerhub username"
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



COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});
DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});
MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});
CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
	if [ "$UPDATE" == "1" ]; then
	    sudo bash /app/onlyoffice/setup/tools/check-bindings.sh ${COMMUNITY_SERVER_ID}

		COMMUNITY_PORT=$(sudo docker port $COMMUNITY_SERVER_ID 80 | sed 's/.*://')

		sudo bash /app/onlyoffice/setup/tools/remove-container.sh ${COMMUNITY_CONTAINER_NAME}
	else
		echo "ONLYOFFICE COMMUNITY SERVER is already installed."
		sudo docker start ${COMMUNITY_SERVER_ID};
		echo "INSTALLATION-STOP-SUCCESS"
		exit 0;
	fi
fi

if [[ -n ${USERNAME} && -n ${PASSWORD}  ]]; then
	sudo bash /app/onlyoffice/setup/tools/login-docker.sh ${USERNAME} ${PASSWORD}
fi

if [[ -z ${VERSION} ]]; then
	GET_VERSION_COMMAND="sudo bash /app/onlyoffice/setup/tools/get-available-version.sh -i $COMMUNITY_IMAGE_NAME";

	if [[ -n ${PASSWORD} && -n ${USERNAME} ]]; then
	    GET_VERSION_COMMAND="$GET_VERSION_COMMAND -un $USERNAME -p $PASSWORD";
	fi

	VERSION=$(${GET_VERSION_COMMAND});
fi

RUN_COMMAND="sudo docker run --net onlyoffice --name $COMMUNITY_CONTAINER_NAME -i -t -d --restart=always -p $COMMUNITY_PORT:80 -p 443:443 -p 5222:5222";
RUN_COMMAND="$RUN_COMMAND  -e ONLYOFFICE_MONOSERVE_COUNT=2";

if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
	RUN_COMMAND="$RUN_COMMAND  -e DOCUMENT_SERVER_PORT_80_TCP_ADDR=$DOCUMENT_CONTAINER_NAME";
fi

if [[ -n ${MAIL_SERVER_ID} ]]; then
	RUN_COMMAND="$RUN_COMMAND  -e MAIL_SERVER_DB_HOST=${MAIL_CONTAINER_NAME}";
fi

if [[ -n ${CONTROL_PANEL_ID} ]]; then
	RUN_COMMAND="$RUN_COMMAND  -e CONTROL_PANEL_PORT_80_TCP=80";
	RUN_COMMAND="$RUN_COMMAND  -e CONTROL_PANEL_PORT_80_TCP_ADDR=$CONTROLPANEL_CONTAINER_NAME";
fi

RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/data:/var/www/onlyoffice/Data";
RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/mysql:/var/lib/mysql";
RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/logs:/var/log/onlyoffice";
RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/DocumentServerData";
RUN_COMMAND="$RUN_COMMAND $COMMUNITY_IMAGE_NAME:$VERSION";

${RUN_COMMAND};

COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});

if [[ -z ${COMMUNITY_SERVER_ID} ]]; then
	echo "ONLYOFFICE COMMUNITY SERVER not installed."
	echo "INSTALLATION-STOP-ERROR"
	exit 0;
fi

echo "ONLYOFFICE COMMUNITY SERVER successfully installed."
echo "INSTALLATION-STOP-SUCCESS"