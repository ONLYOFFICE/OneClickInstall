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
CONTROLPANEL_IMAGE_NAME='onlyoffice/controlpanel';
CONTROLPANEL_CONTAINER_NAME='onlyoffice-control-panel';

while [ "$1" != "" ]; do
	case $1 in

		-u | --update )
			UPDATE=1
		;;

		-i | --image )
			if [ "$2" != "" ]; then
				CONTROLPANEL_IMAGE_NAME=$2
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
			echo "      -p, --password          dockerhub password"
			echo "      -un, --username          dockerhub username"
			echo "      -?, -h, --help          this help"
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



CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

if [[ -n ${CONTROL_PANEL_ID} ]]; then
	if [ "$UPDATE" == "1" ]; then
	    sudo bash /app/onlyoffice/setup/tools/check-bindings.sh ${CONTROL_PANEL_ID}
		sudo bash /app/onlyoffice/setup/tools/remove-container.sh ${CONTROLPANEL_CONTAINER_NAME}
	else
		echo "ONLYOFFICE CONTROL PANEL is already installed."
		sudo docker start ${CONTROL_PANEL_ID};
		echo "INSTALLATION-STOP-SUCCESS"
		exit 0;
	fi
fi

if [[ -n ${USERNAME} && -n ${PASSWORD}  ]]; then
	sudo bash /app/onlyoffice/setup/tools/login-docker.sh ${USERNAME} ${PASSWORD}
fi

if [[ -z ${VERSION} ]]; then
	GET_VERSION_COMMAND="sudo bash /app/onlyoffice/setup/tools/get-available-version.sh -i $CONTROLPANEL_IMAGE_NAME";

	if [[ -n ${PASSWORD} && -n ${USERNAME} ]]; then
	    GET_VERSION_COMMAND="$GET_VERSION_COMMAND -un $USERNAME -p $PASSWORD";
	fi

	VERSION=$(${GET_VERSION_COMMAND});
fi

sudo bash /app/onlyoffice/setup/tools/pull-image.sh ${CONTROLPANEL_IMAGE_NAME} ${VERSION}

sudo docker run --net onlyoffice -i -t -d --restart=always --name ${CONTROLPANEL_CONTAINER_NAME} \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /app/onlyoffice/CommunityServer/data:/app/onlyoffice/CommunityServer/data \
-v /app/onlyoffice/DocumentServer/data:/app/onlyoffice/DocumentServer/data \
-v /app/onlyoffice/MailServer/data:/app/onlyoffice/MailServer/data \
-v /app/onlyoffice/ControlPanel/data:/var/www/onlyoffice-controlpanel/Data \
-v /app/onlyoffice/ControlPanel/logs:/var/log/onlyoffice-controlpanel \
-v /app/onlyoffice/ControlPanel/mysql:/var/lib/mysql \
${CONTROLPANEL_IMAGE_NAME}:${VERSION}

CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

if [[ -z ${CONTROL_PANEL_ID} ]]; then
	echo "ONLYOFFICE CONTROL PANEL not installed."
	echo "INSTALLATION-STOP-ERROR"
	exit 0;
fi

echo "ONLYOFFICE CONTROL PANEL successfully installed."
echo "INSTALLATION-STOP-SUCCESS"