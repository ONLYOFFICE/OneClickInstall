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

#!/bin/bash

while [ "$1" != "" ]; do
	case $1 in
		-i | --image )
			IMAGE=$2
			shift
		;;
		
		-un | --username )
			USERNAME=$2
			shift
		;;
		
		-p | --password )
			PASSWORD=$2
			shift
		;;

		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -i, --image         image"
			echo "      -un, --username     dockerhub username"
			echo "      -p, --password      dockerhub password"
			echo "      -?, -h, --help      this help"
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



command_exists () {
    type "$1" &> /dev/null;
}

install_curl () {
	if command_exists apt-get; then
		sudo apt-get -y -q install curl
	elif command_exists yum; then
		sudo yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 0;
	fi
}



if [ "$IMAGE" == "" ]; then
	echo "image name is empty"
	exit 0
fi

if ! command_exists curl ; then
	install_curl;
fi

CREDENTIALS="";
AUTH_HEADER="";

if [[ -n ${USERNAME} && -n ${PASSWORD} ]]; then
	CREDENTIALS="{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}";
fi

if [[ -n ${CREDENTIALS} ]]; then
	LOGIN_RESP=$(curl -s -H "Content-Type: application/json" -X POST -d "$CREDENTIALS" https://hub.docker.com/v2/users/login/)
	TOKEN=$(echo $LOGIN_RESP | sed 's/"token"//g' | tr -d '{}:" ')
	AUTH_HEADER="Authorization: JWT $TOKEN"
fi

TAGS_RESP=$(curl -s -H "$AUTH_HEADER" -X GET https://hub.docker.com/v2/repositories/${IMAGE}/tags/);
TAGS_RESP=$(echo $TAGS_RESP | tr -d '[]{},:"')

VERSION_REGEX_1="[0-9]+\.[0-9]+\.[0-9]+"
VERSION_REGEX_2="[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"
TAG_LIST=""

for item in $TAGS_RESP
do
	if [[ $item =~ $VERSION_REGEX_1 ]] || [[ $item =~ $VERSION_REGEX_2 ]]; then
		TAG_LIST="$item,$TAG_LIST"
	fi
done

LATEST_TAG=$(echo $TAG_LIST | tr ',' '\n' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | awk '/./{line=$0} END{print line}');

echo "$LATEST_TAG"

