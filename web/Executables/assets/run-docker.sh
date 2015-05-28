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
ARCH_TYPE=${3}
KERNEL=${4}
IS_REBOOT=${5:-false}

EXIT_STATUS=-1;
EXIT_NOT_SUPPORTED_OS_STATUS=10;


command_exists () {
    type "$1" &> /dev/null ;
}

if command_exists docker ; then
    echo "docker is already installed."
    echo "INSTALLATION-STOP-SUCCESS"
    exit 0;
fi


if [ "${ARCH_TYPE}" != "x86_64" ]; then
	echo "Currently only supports 64bit OS's";
	echo "INSTALLATION-STOP-ERROR[1]"
	exit 0;
fi

REV_PARTS=(${REV//\./ })
REV=${REV_PARTS[0]}

if [ "${DIST}" == "Ubuntu" ]; then

	if [ "${REV}" -ge "14" ]; then
		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y -q --force-yes install curl
		sudo curl -sSL https://get.docker.com/ | sh
	elif [ "${REV}" -eq "13" ]; then
		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y install linux-image-extra-`uname -r`
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
		sudo sh -c "echo deb http://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
		sudo apt-get -y update
		sudo apt-get -y install lxc-docker
	elif [ "${REV}" -eq "12" ]; then
		# install the backported kernel
		sudo apt-get -y update
		sudo apt-get -y -q --force-yes install linux-image-generic-lts-trusty

		# reboot
		if [ "${IS_REBOOT}" == "false" ] ; then
 			echo "INSTALLATION-STOP-REBOOT"
			exit 0;
		fi
		
		sudo apt-get -y -q --force-yes update
		sudo apt-get -y -q --force-yes install wget
		sudo wget -qO- https://get.docker.com/ | sh               
 
	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi
	
elif [ "${DIST}" == "Debian" ]; then
	
	if [ "${REV}" -ge "8" ]; then
		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y -q --force-yes install curl
		sudo curl -sSL https://get.docker.com/ | sh
	elif [ "${REV}" -eq "7" ]; then
		echo "deb http://http.debian.net/debian wheezy-backports main" >>  /etc/apt/sources.list
		sudo apt-get -y update
		sudo apt-get -y upgrade
		sudo apt-get -y -q --force-yes install curl
		sudo apt-get -y -q --force-yes install -t wheezy-backports linux-image-amd64 

		# reboot
		if [ "${IS_REBOOT}" == "false" ] ; then
 			echo "INSTALLATION-STOP-REBOOT"
			exit 0;
		fi

		curl -sSL https://get.docker.com/ | sh
	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi
	
elif [[ "${DIST}" == CentOS* ]] || [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then
	
	if [ "${REV}" -ge "7" ]; then
                
		if [ "${DIST}" == "Red Hat Enterprise Linux Server" ]; then
			sudo yum -y install yum-utils
			sudo yum-config-manager --enable rhui-REGION-rhel-server-extras
		fi
		
		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y install docker
		sudo setenforce 0
		sudo systemctl stop firewalld.service
		sudo systemctl disable firewalld.service
		sudo systemctl start docker.service
		sudo systemctl enable docker.service
	elif [ "${REV}" -eq "6" ]; then
		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y install epel-release
		sudo yum -y install docker-io
		sudo service docker start
		sudo chkconfig docker on
	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi
	
elif [ "${DIST}" == "SuSe" ]; then
	
	if [ "${REV}" -ge "13" ]; then
		sudo zypper ar -f http://download.opensuse.org/repositories/Virtualization/openSUSE_13.1/ Virtualization
		sudo zypper --non-interactive in docker
		sudo systemctl start docker
		sudo systemctl enable docker
	elif [ "${REV}" -ge "12" ]; then
		sudo zypper ar -f http://download.opensuse.org/repositories/Virtualization/openSUSE_12.3/ Virtualization
		sudo zypper --non-interactive in docker
		sudo systemctl start docker
		sudo systemctl enable docker
	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi
	
elif [ "${DIST}" == "Fedora" ]; then
	
	if [ "${REV}" -ge "21" ]; then
		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y install docker
		sudo setenforce 0
		sudo systemctl start docker
		sudo systemctl enable docker
	elif [ "${REV}" -eq "20" ]; then
		sudo yum -y update
		sudo yum -y upgrade
		sudo yum -y remove docker
		sudo yum -y install docker-io	
		sudo systemctl start docker
		sudo systemctl enable docker
	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi

else
	EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
fi

if [ ${EXIT_STATUS} -eq ${EXIT_NOT_SUPPORTED_OS_STATUS} ]; then
    echo "Not supported OS"
    echo "INSTALLATION-STOP-ERROR[2]"
    exit 0;
fi

if command_exists docker ; then
    echo "docker successfully installed."
    echo "INSTALLATION-STOP-SUCCESS"
    exit 0;
fi

echo "error while installing docker."
echo "INSTALLATION-STOP-ERROR[6]"
