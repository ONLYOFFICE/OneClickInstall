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

DISK_REQUIREMENTS=${1};
MEMORY_REQUIREMENTS=${2};
CORE_REQUIREMENTS=${3};

to_lowercase () {
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

get_os_info () {
	OS=`to_lowercase \`uname\``

	if [ "${OS}" == "windowsnt" ]; then
		echo "Not supported OS"
		echo "INSTALLATION-STOP-ERROR[2]"
		exit 0;
	elif [ "${OS}" == "darwin" ]; then
		echo "Not supported OS"
		echo "INSTALLATION-STOP-ERROR[2]"
		exit 0;
	else
		OS=`uname`

		if [ "${OS}" = "SunOS" ] ; then
			echo "Not supported OS"
			echo "INSTALLATION-STOP-ERROR[2]"
			exit 0;
		elif [ "${OS}" = "AIX" ] ; then
			echo "Not supported OS"
			echo "INSTALLATION-STOP-ERROR[2]"
			exit 0;
		elif [ "${OS}" = "Linux" ] ; then
			MACH=`uname -m`

			if [ "${MACH}" != "x86_64" ]; then
				echo "Currently only supports 64bit OS's";
				echo "INSTALLATION-STOP-ERROR[1]"
				exit 0;
			fi

			KERNEL=`uname -r`

			if [ -f /etc/redhat-release ] ; then
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				REV=`cat /etc/os-release  | grep '^VERSION_ID' | awk -F=  '{ print $2 }' |  sed -e 's/^"//'  -e 's/"$//'`
				DIST='SuSe'
			elif [ -f /etc/debian_version ] ; then
				REV=`cat /etc/debian_version`
				DIST='Debian'
				if [ -f /etc/lsb-release ] ; then
					DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
					REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
				elif [[ -f /etc/lsb_release ]]; then
					DIST=`lsb_release -a 2>&1 | grep 'Distributor ID:' | awk -F ":" '{print $2 }'`
					REV=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
				fi
			fi

			DISK=$(df -m /  | tail -1 | awk '{ print $4 }');

			if [ ${DISK} -lt ${DISK_REQUIREMENTS} ]; then
				echo "Minimal requirements are not met: need at least $DISK_REQUIREMENTS MB of free HDD space"
				echo "INSTALLATION-STOP-ERROR[9]"
				exit 0;
			fi

			MEMORY=$(free -m | awk '/^Mem:/{print $2}');

			if [ ${MEMORY} -lt ${MEMORY_REQUIREMENTS} ]; then
				echo "Minimal requirements are not met: need at least $MEMORY_REQUIREMENTS MB of RAM"
				echo "INSTALLATION-STOP-ERROR[9]"
				exit 0;
			fi

			CORE=$(cat /proc/cpuinfo | grep processor | wc -l);

			if [ ${CORE} -lt ${CORE_REQUIREMENTS} ]; then
				echo "The system does not meet the minimal hardware requirements. CPU with at least $CORE_REQUIREMENTS cores is required"
				echo "INSTALLATION-STOP-ERROR[9]"
				exit 0;
			fi

			readonly DIST
			readonly REV
			readonly KERNEL
			readonly MACH
			readonly DISK
			readonly MEMORY
			readonly CORE

		fi
	fi
}



get_os_info

echo "DIST: [$DIST]"
echo "REV: [$REV]"
echo "MACH: [$MACH]"
echo "KERNEL: [$KERNEL]"
echo "DISK: [$DISK]"
echo "MEMORY: [$MEMORY]"
echo "CORE: [$CORE]"

echo "INSTALLATION-STOP-SUCCESS"