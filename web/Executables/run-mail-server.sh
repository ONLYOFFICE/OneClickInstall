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
MAIL_IMAGE_NAME='onlyoffice/mailserver';
MAIL_CONTAINER_NAME='onlyoffice-mail-server';

while [ "$1" != "" ]; do
	case $1 in

		-u | --update )
			UPDATE=1
		;;

		-i | --image )
			if [ "$2" != "" ]; then
				MAIL_IMAGE_NAME=$2
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
				MAIL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-d | --domain )
			if [ "$2" != "" ]; then
				MAIL_DOMAIN_NAME=$2
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
			echo "      -d, --domain          domain name"
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



MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

if [[ -n ${MAIL_SERVER_ID} ]]; then
	if [ "$UPDATE" == "1" ]; then
	    sudo bash /app/onlyoffice/setup/tools/check-bindings.sh ${MAIL_SERVER_ID}

		if  [[ -z ${MAIL_DOMAIN_NAME} ]]; then
			MAIL_DOMAIN_NAME=$(sudo docker exec $MAIL_SERVER_ID hostname -f);
		fi

		sudo bash /app/onlyoffice/setup/tools/remove-container.sh ${MAIL_CONTAINER_NAME}
	else
		echo "ONLYOFFICE MAIL SERVER is already installed."
		sudo docker start ${MAIL_SERVER_ID};
		echo "INSTALLATION-STOP-SUCCESS"
		exit 0;
	fi
fi

if [[ -n ${USERNAME} && -n ${PASSWORD}  ]]; then
	sudo bash /app/onlyoffice/setup/tools/login-docker.sh ${USERNAME} ${PASSWORD}
fi

if [[ -z ${VERSION} ]]; then
	GET_VERSION_COMMAND="sudo bash /app/onlyoffice/setup/tools/get-available-version.sh -i $MAIL_IMAGE_NAME";

	if [[ -n ${PASSWORD} && -n ${USERNAME} ]]; then
	    GET_VERSION_COMMAND="$GET_VERSION_COMMAND -un $USERNAME -p $PASSWORD";
	fi

	VERSION=$(${GET_VERSION_COMMAND});
fi

if  [[ -z ${MAIL_DOMAIN_NAME} ]]; then
	echo "Please, set domain name for mail server"
	echo "INSTALLATION-STOP-ERROR[4]"
	exit 0;
fi

sudo bash /app/onlyoffice/setup/tools/pull-image.sh ${MAIL_IMAGE_NAME} ${VERSION}

sudo docker run --net onlyoffice --privileged -i -t -d --restart=always --name ${MAIL_CONTAINER_NAME} -p 25:25 -p 143:143 -p 587:587 \
-v /app/onlyoffice/MailServer/data:/var/vmail \
-v /app/onlyoffice/MailServer/data/certs:/etc/pki/tls/mailserver \
-v /app/onlyoffice/MailServer/logs:/var/log \
-v /app/onlyoffice/MailServer/mysql:/var/lib/mysql \
-h ${MAIL_DOMAIN_NAME} ${MAIL_IMAGE_NAME}:${VERSION}

MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

if [[ -z ${MAIL_SERVER_ID} ]]; then
	echo "ONLYOFFICE MAIL SERVER not installed."
	echo "INSTALLATION-STOP-ERROR"
	exit 0;
fi

echo "ONLYOFFICE MAIL SERVER successfully installed."
echo "INSTALLATION-STOP-SUCCESS"