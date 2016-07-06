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

if [[ -z "$1" ]]; then
	echo "container id is empty";
	exit 0;
fi

binds=$(sudo docker inspect --format='{{range $p,$conf:=.HostConfig.Binds}}{{$conf}};{{end}}' $1)
volumes=$(sudo docker inspect --format='{{range $p,$conf:=.Config.Volumes}}{{$p}};{{end}}' $1)
arrBinds=$(echo $binds | tr ";" "\n")
arrVolumes=$(echo $volumes | tr ";" "\n")
bindsCorrect=1

if [[ -n "$2" ]]; then
	exceptions=$(echo $2 | tr "," "\n")
	for ex in ${exceptions[@]}
	do
		arrVolumes=(${arrVolumes[@]/$ex})
	done
fi

for volume in $arrVolumes
do
	bindExist=0
	for bind in $arrBinds
	do
		bind=($(echo $bind | tr ":" " "))
		if [ "${bind[1]}" == "${volume}" ]; then
			bindExist=1
		fi
	done
	if [ "$bindExist" = "0" ]; then
		bindsCorrect=0
		echo "${volume} not binded"
	fi
done

if [ "$bindsCorrect" = "0" ]; then
	echo "INSTALLATION-STOP-ERROR";
	exit 0;
fi
