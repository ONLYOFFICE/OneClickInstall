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

remove_container () {
	CONTAINER_NAME=$1;

	if [[ -z ${CONTAINER_NAME} ]]; then
		echo "Empty container name"
		echo "INSTALLATION-STOP-ERROR";
		exit 0;
	fi

	echo "stop container:"
	sudo docker stop ${CONTAINER_NAME};
	echo "remove container:"
	sudo docker rm -f ${CONTAINER_NAME};

	sleep 10 #Hack for SuSe: exception "Error response from daemon: devmapper: Unknown device xxx"

	echo "check removed container:"
	CONTAINER_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTAINER_NAME});

	if [[ -n ${CONTAINER_ID} ]]; then
		echo "try again remove ${CONTAINER_NAME}"
		remove_container ${CONTAINER_NAME}
	fi
}

remove_container $1
