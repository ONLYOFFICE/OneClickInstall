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

EXIST=$(sudo swapon -s | awk '{ print $1 }' | grep -x '/onlyoffice_swapfile');

if [[ -z $EXIST ]]; then
	sudo fallocate -l 6G /onlyoffice_swapfile
	sudo chmod 600 /onlyoffice_swapfile
	sudo mkswap /onlyoffice_swapfile
	sudo swapon /onlyoffice_swapfile
	sudo echo "/onlyoffice_swapfile none swap sw 0 0" >> /etc/fstab
fi

echo "INSTALLATION-STOP-SUCCESS"