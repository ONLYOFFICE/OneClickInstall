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

lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

shootProfile(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [ "${OS}" == "windowsnt" ]; then
		OS=windows
	elif [ "${OS}" == "darwin" ]; then
		OS=mac
	else
		OS=`uname`
		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [ "${OS}" = "Linux" ] ; then
			
			if [ -f /etc/redhat-release ] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				DistroBasedOn='SuSe'
				PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [ -f /etc/mandrake-release ] ; then
				DistroBasedOn='Mandrake'
				PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/debian_version ] ; then
				DistroBasedOn='Debian'
				REV=`cat /etc/debian_version`
				DIST=$DistroBasedOn

				if [ -f /etc/lsb-release ] ; then
					DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
					PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
					REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
				elif [[ -f /etc/lsb_release ]]; then
					DIST=`lsb_release -a 2>&1 | grep 'Distributor ID:' | awk -F ":" '{print $2 }'`
					PSUEDONAME=`lsb_release -a 2>&1 | grep 'Codename:' | awk -F ":" '{print $2 }'`
					REV=`lsb_release -a 2>&1 | grep 'Release:' | awk -F ":" '{print $2 }'`
				fi
			fi

			if [ -f /etc/UnitedLinux-release ] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
			readonly OS
			readonly DIST
			readonly DistroBasedOn
			readonly PSUEDONAME
			readonly REV
			readonly KERNEL
			readonly MACH
		fi

	fi
}

shootProfile

echo "OS: [$OS]"
echo "DIST: [$DIST]"
echo "REV: [$REV]"
echo "MACH: [$MACH]"
echo "PSUEDONAME: [$PSUEDONAME]"
echo "DistroBasedOn: [$DistroBasedOn]"
echo "KERNEL: [$KERNEL]"

echo "INSTALLATION-STOP-SUCCESS"