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

IMAGE_NAME=$1;
IMAGE_VERSION=$2;

if [[ -z ${IMAGE_NAME} || -z ${IMAGE_VERSION} ]]; then
	echo "Docker pull argument exception: repository=$IMAGE_NAME, tag=$IMAGE_VERSION"
	echo "INSTALLATION-STOP-ERROR";
	exit 0;
fi

EXIST=$(sudo docker images | grep "$IMAGE_NAME" | awk '{print $2;}' | grep -x "$IMAGE_VERSION");
COUNT=1;

while [[ -z $EXIST && $COUNT -le 3 ]]; do
	sudo docker pull ${IMAGE_NAME}:${IMAGE_VERSION}
	EXIST=$(sudo docker images | grep "$IMAGE_NAME" | awk '{print $2;}' | grep -x "$IMAGE_VERSION");
	(( COUNT++ ))
done

if [[ -z $EXIST ]]; then
	echo "Docker image $IMAGE_NAME:$IMAGE_VERSION not found"
	echo "INSTALLATION-STOP-ERROR";
	exit 0;
fi
