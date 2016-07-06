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

DIST=${1}
REV=${2}
KERNEL=${3}
ARCH_TYPE=${4}



check_os_info () {
	if [[ -z ${DIST} || -z ${REV} || -z ${KERNEL} || -z ${ARCH_TYPE} ]]; then
		echo "Not supported OS"
		echo "INSTALLATION-STOP-ERROR[2]"
		exit 0;
	fi
	
	if [ "${ARCH_TYPE}" != "x86_64" ]; then
		echo "Currently only supports 64bit OS's";
		echo "INSTALLATION-STOP-ERROR[1]"
		exit 0;
	fi
}

check_kernel () {
	MIN_NUM_ARR=(3 10 0);
	CUR_NUM_ARR=();

	CUR_STR_ARR=$(echo $KERNEL | grep -Po "[0-9]+\.[0-9]+\.[0-9]+" | tr "." " ");
	for CUR_STR_ITEM in $CUR_STR_ARR
	do
		CUR_NUM_ARR=(${CUR_NUM_ARR[@]} $CUR_STR_ITEM)
	done

	INDEX=0;

	while [[ $INDEX -lt 3 ]]; do
		if [ ${CUR_NUM_ARR[INDEX]} -lt ${MIN_NUM_ARR[INDEX]} ]; then
			echo "Not supported OS Kernel"
			echo "INSTALLATION-STOP-ERROR[7]"
			exit 0;
		elif [ ${CUR_NUM_ARR[INDEX]} -gt ${MIN_NUM_ARR[INDEX]} ]; then
			INDEX=3
		fi
		(( INDEX++ ))
	done
}

command_exists () {
    type "$1" &> /dev/null;
}

check_docker_version () {
	MIN_NUM_ARR=(1 10 0);
	CUR_NUM_ARR=();

	CUR_STR_ARR=$(docker -v | grep -Po "[0-9]+\.[0-9]+\.[0-9]+" | tr "." " ");
	for CUR_STR_ITEM in $CUR_STR_ARR
	do
		CUR_NUM_ARR=(${CUR_NUM_ARR[@]} $CUR_STR_ITEM)
	done

	NEED_UPDATE="false"
	INDEX=0;

	while [[ $INDEX -lt 3 ]]; do
		if [ ${CUR_NUM_ARR[INDEX]} -lt ${MIN_NUM_ARR[INDEX]} ]; then
			NEED_UPDATE="true"
			INDEX=3
		elif [ ${CUR_NUM_ARR[INDEX]} -gt ${MIN_NUM_ARR[INDEX]} ]; then
			INDEX=3
		fi
		(( INDEX++ ))
	done

	echo "$NEED_UPDATE"
}

uninstall_docker () {

	if [ "${DIST}" == "Ubuntu" ] || [ "${DIST}" == "Debian" ]; then

		sudo apt-get -y autoremove --purge docker-engine

	elif [[ "${DIST}" == CentOS* ]] || [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then

		sudo yum -y remove docker-engine.x86_64

	elif [ "${DIST}" == "SuSe" ]; then

		sudo zypper rm -y docker

	elif [ "${DIST}" == "Fedora" ]; then

		sudo dnf -y remove docker-engine.x86_64

	else
		echo "Not supported OS"
		echo "INSTALLATION-STOP-ERROR[2]"
		exit 0;
	fi
}

install_docker () {

	if [ "${DIST}" == "Ubuntu" ] || [ "${DIST}" == "Debian" ]; then

		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y -q install curl
		sudo curl -sSL https://get.docker.com/ | sh

	elif [[ "${DIST}" == CentOS* ]] || [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then

		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y install curl
		sudo curl -fsSL https://get.docker.com/ | sh
		sudo service docker start

	elif [ "${DIST}" == "SuSe" ]; then

		sudo zypper in -y docker
		sudo systemctl start docker
		sudo systemctl enable docker

	elif [ "${DIST}" == "Fedora" ]; then

		sudo dnf -y update
		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y install curl
		sudo curl -fsSL https://get.docker.com/ | sh
		sudo systemctl start docker
		sudo systemctl enable docker

	else
		echo "Not supported OS"
		echo "INSTALLATION-STOP-ERROR[2]"
		exit 0;
	fi

	if ! command_exists docker ; then
		echo "Error while installing docker"
		echo "INSTALLATION-STOP-ERROR[6]"
		exit 0;
	fi
	
	echo "Docker successfully installed"
	echo "INSTALLATION-STOP-SUCCESS"
	exit 0;
}



check_os_info

check_kernel

if command_exists docker ; then
	NEED_UPDATE=$(check_docker_version);

	if [ "$NEED_UPDATE" == "true" ]; then
		uninstall_docker
		install_docker
	else
		echo "Docker successfully installed"
		echo "INSTALLATION-STOP-SUCCESS"
		exit 0;
	fi
else
	install_docker
fi
