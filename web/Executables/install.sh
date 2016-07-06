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

COMMUNITY_CONTAINER_NAME="onlyoffice-community-server";
DOCUMENT_CONTAINER_NAME="onlyoffice-document-server";
MAIL_CONTAINER_NAME="onlyoffice-mail-server";
CONTROLPANEL_CONTAINER_NAME="onlyoffice-control-panel";

COMMUNITY_IMAGE_NAME="onlyoffice4enterprise/communityserver-ee";
DOCUMENT_IMAGE_NAME="onlyoffice4enterprise/documentserver-ee";
MAIL_IMAGE_NAME="onlyoffice/mailserver";
CONTROLPANEL_IMAGE_NAME="onlyoffice4enterprise/controlpanel-ee";

COMMUNITY_VERSION="";
DOCUMENT_VERSION="";
MAIL_VERSION="";
CONTROLPANEL_VERSION="";

MAIL_SERVER_HOST="";
DOCUMENT_SERVER_HOST="";

LICENSE_FILE_PATH="";
MAIL_DOMAIN_NAME="";

DIST="";
REV="";
KERNEL="";

AFTER_REBOOT="false";
UPDATE="false";

EMAIL="";
PASSWORD="";
USERNAME="";

INSTALL_COMMUNITY_SERVER="true"
INSTALL_DOCUMENT_SERVER="true"
INSTALL_MAIL_SERVER="true"
INSTALL_CONTROLPANEL="true"

PULL_COMMUNITY_SERVER="false"
PULL_DOCUMENT_SERVER="false"
PULL_MAIL_SERVER="false"
PULL_CONTROLPANEL="false"

USE_AS_EXTERNAL_SERVER="false"

while [ "$1" != "" ]; do
	case $1 in

		-cc | --communitycontainer )
			if [ "$2" != "" ]; then
				COMMUNITY_CONTAINER_NAME=$2
				shift
			fi
		;;

		-dc | --documentcontainer )
			if [ "$2" != "" ]; then
				DOCUMENT_CONTAINER_NAME=$2
				shift
			fi
		;;

		-mc | --mailcontainer )
			if [ "$2" != "" ]; then
				MAIL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-cpc | --controlpanelcontainer )
			if [ "$2" != "" ]; then
				CONTROLPANEL_CONTAINER_NAME=$2
				shift
			fi
		;;

		-ci | --communityimage )
			if [ "$2" != "" ]; then
				COMMUNITY_IMAGE_NAME=$2
				shift
			fi
		;;

		-di | --documentimage )
			if [ "$2" != "" ]; then
				DOCUMENT_IMAGE_NAME=$2
				shift
			fi
		;;

		-mi | --mailimage )
			if [ "$2" != "" ]; then
				MAIL_IMAGE_NAME=$2
				shift
			fi
		;;

		-cpi | --controlpanelimage )
			if [ "$2" != "" ]; then
				CONTROLPANEL_IMAGE_NAME=$2
				shift
			fi
		;;

		-dip | --documentserverip  )
			if [ "$2" != "" ]; then
				DOCUMENT_SERVER_HOST=$2
				shift
			fi
		;;
		
		-mip | --mailserverip  )
			if [ "$2" != "" ]; then
				MAIL_SERVER_HOST=$2
				shift
			fi
		;;
		
		-cv | --communityversion )
			if [ "$2" != "" ]; then
				COMMUNITY_VERSION=$2
				shift
			fi
		;;

		-dv | --documentversion )
			if [ "$2" != "" ]; then
				DOCUMENT_VERSION=$2
				shift
			fi
		;;

		-mv | --mailversion )
			if [ "$2" != "" ]; then
				MAIL_VERSION=$2
				shift
			fi
		;;

		-cpv | --controlpanelversion )
			if [ "$2" != "" ]; then
				CONTROLPANEL_VERSION=$2
				shift
			fi
		;;

		-lf | --licensefile )
			if [ "$2" != "" ]; then
				LICENSE_FILE_PATH=$2
				shift
			fi
		;;

		-md | --maildomain )
			if [ "$2" != "" ]; then
				MAIL_DOMAIN_NAME=$2
				shift
			fi
		;;

		-ar | --afterreboot )
			if [ "$2" != "" ]; then
				AFTER_REBOOT=$2
				shift
			fi
		;;

		-u | --update )
			if [ "$2" != "" ]; then
				UPDATE=$2
				shift
			fi
		;;

		-e | --email )
			if [ "$2" != "" ]; then
				EMAIL=$2
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

		-ics | --installcommunityserver )
			if [ "$2" != "" ]; then
				INSTALL_COMMUNITY_SERVER=$2
				shift
			fi
		;;

		-ids | --installdocumentserver )
			if [ "$2" != "" ]; then
				INSTALL_DOCUMENT_SERVER=$2
				shift
			fi
		;;

		-ims | --installmailserver )
			if [ "$2" != "" ]; then
				INSTALL_MAIL_SERVER=$2
				shift
			fi
		;;

		-icp | --installcontrolpanel )
			if [ "$2" != "" ]; then
				INSTALL_CONTROLPANEL=$2
				shift
			fi
		;;

		-pcs | --pullcommunityserver )
			if [ "$2" != "" ]; then
				PULL_COMMUNITY_SERVER=$2
				shift
			fi
		;;

		-pds | --pulldocumentserver )
			if [ "$2" != "" ]; then
				PULL_DOCUMENT_SERVER=$2
				shift
			fi
		;;

		-pms | --pullmailserver )
			if [ "$2" != "" ]; then
				PULL_MAIL_SERVER=$2
				shift
			fi
		;;

		-pcp | --pullcontrolpanel )
			if [ "$2" != "" ]; then
				PULL_CONTROLPANEL=$2
				shift
			fi
		;;
		
		-es | --useasexternalserver )
			if [ "$2" != "" ]; then
				USE_AS_EXTERNAL_SERVER=$2
				shift
			fi
		;;
		
		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -cc, --communitycontainer         community container name"
			echo "      -dc, --documentcontainer          document container name"
			echo "      -mc, --mailcontainer              mail container name"
			echo "      -cpc, --controlpanelcontainer     control panel container name"
			echo "      -ci, --communityimage             community image name"
			echo "      -di, --documentimage              document image name"
			echo "      -mi, --mailimage                  mail image name"
			echo "      -cpi, --controlpanelimage         control panel image name"
			echo "      -cv, --communityversion           community version"
			echo "      -dv, --documentversion            document version"
			echo "      -dip, --documentserverip          document server ip"
			echo "      -mv, --mailversion                mail version"
			echo "      -mip, --mailserverip              mail server ip"
			echo "      -cpv, --controlpanelversion       control panel version"
			echo "      -lf, --licensefile                license file path"
			echo "      -md, --maildomain                 mail domail name"
			echo "      -ar, --afterreboot                use to continue installation after reboot (true|false)"
			echo "      -u, --update                      use to update existing components (true|false)"
			echo "      -e, --email                       dockerhub email"
			echo "      -p, --password                    dockerhub password"
			echo "      -un, --username                   dockerhub username"
			echo "      -ics, --installcommunityserver    install community server (true|false)"
			echo "      -ids, --installdocumentserver     install document server (true|false)"
			echo "      -ims, --installmailserver         install mail server (true|false)"
			echo "      -icp, --installcontrolpanel       install control panel (true|false)"
			echo "      -pcs, --pullcommunityserver       pull community server (true|false)"
			echo "      -pds, --pulldocumentserver        pull document server (true|false)"
			echo "      -pms, --pullmailserver            pull mail server (true|false)"
			echo "      -pcp, --pullcontrolpanel          pull control panel (true|false)"
			echo "      -es, --useasexternalserver        use as external server (true|false)"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

		* )
			echo "Unknown parameter $1" 1>&2
			exit 0
		;;
	esac
	shift
done



root_checking () {
	if [ ! $( id -u ) -eq 0 ]; then
		echo "To perform this action you must be logged in with root rights"
		exit 0;
	fi
}

command_exists () {
    type "$1" &> /dev/null;
}

file_exists () {
	if [ -z "$1" ]; then
		echo "file path is empty"
		exit 0;
	fi

	if [ -f "$1" ]; then
		return 0; #true
	else
		return 1; #false
	fi
}

install_sudo () {
	if command_exists apt-get; then
		apt-get install sudo 
	elif command_exists yum; then
		yum install sudo
	fi

	if ! command_exists sudo; then
		echo "command sudo not found"
		exit 0;
	fi
}

install_curl () {
	if command_exists apt-get; then
		sudo apt-get -y -q --force-yes install curl 
	elif command_exists yum; then
		sudo yum -y install curl
	fi

	if ! command_exists curl; then
		echo "command curl not found"
		exit 0;
	fi
}

to_lowercase () {
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

get_os_info () {
	OS=`to_lowercase \`uname\``

	if [ "${OS}" == "windowsnt" ]; then
		echo "Not supported OS";
		exit 0;
	elif [ "${OS}" == "darwin" ]; then
		echo "Not supported OS";
		exit 0;
	else
		OS=`uname`

		if [ "${OS}" = "SunOS" ] ; then
			echo "Not supported OS";
			exit 0;
		elif [ "${OS}" = "AIX" ] ; then
			echo "Not supported OS";
			exit 0;
		elif [ "${OS}" = "Linux" ] ; then
			MACH=`uname -m`

			if [ "${MACH}" != "x86_64" ]; then
				echo "Currently only supports 64bit OS's";
				exit 0;
			fi

			KERNEL=`uname -r`

			if [ -f /etc/redhat-release ] ; then
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				REV=`cat /etc/os-release  | grep '^VERSION_ID' | awk -F=  '{ print $2 }'`
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
		fi
	fi
}

check_kernel () {
	if [[ -z ${KERNEL} ]]; then
		echo "Not supported OS";
		exit 0;
	fi
}

check_ports () {
	STR_PORTS="80, 443, 5222, 25, 143, 587"
	ARRAY_PORTS=(${STR_PORTS//,/ })

	for PORT in "${ARRAY_PORTS[@]}"
	do
		REGEXP=":$PORT$"
		CHECK_RESULT=$(sudo netstat -lnp | awk '{print $4}' | grep $REGEXP)

		if [[ $CHECK_RESULT != "" ]]; then
			echo "The following ports must be open: $PORT"
			exit 0;
		fi
	done
}

install_docker () {

	EXIT_STATUS=-1;
	EXIT_NOT_SUPPORTED_OS_STATUS=10;

	REV_PARTS=(${REV//\./ });
	REV=${REV_PARTS[0]};

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
			if [ "${AFTER_REBOOT}" != "true" ] ; then
				echo "Please reboot your computer and run installation once again with parameter '--afterreboot true'"
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
			if [ "${AFTER_REBOOT}" != "true" ] ; then
				echo "Please reboot your computer and run installation once again with parameter '--afterreboot true'"
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
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-7/RPMS/x86_64/docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.el7.centos.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -eq "6" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/centos-6/RPMS/x86_64/docker-engine-1.7.1-1.el6.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.el6.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.el6.x86_64.rpm
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

		if [ "${REV}" -ge "22" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-22/RPMS/x86_64/docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo yum -y install --nogpgcheck docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc22.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -ge "21" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-21/RPMS/x86_64/docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc21.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		elif [ "${REV}" -eq "20" ]; then

			sudo yum -y update
			sudo yum -y upgrade
			sudo yum -y install curl
			sudo curl -O -sSL https://get.docker.com/rpm/1.7.1/fedora-20/RPMS/x86_64/docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo yum -y localinstall --nogpgcheck docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo rm docker-engine-1.7.1-1.fc20.x86_64.rpm
			sudo service docker start
			sudo systemctl start docker.service
			sudo systemctl enable docker.service

		else
			EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
		fi

	else
		EXIT_STATUS=${EXIT_NOT_SUPPORTED_OS_STATUS};
	fi

	if [ ${EXIT_STATUS} -eq ${EXIT_NOT_SUPPORTED_OS_STATUS} ]; then
		echo "Not supported OS"
		exit 0;
	fi

	if ! command_exists docker ; then
		echo "error while installing docker"
		exit 0;
	fi
}

docker_login () {
	if [[ -n ${EMAIL} && -n ${PASSWORD} && -n ${USERNAME}  ]]; then
		sudo docker login -e ${EMAIL} -p ${PASSWORD} -u ${USERNAME}
	fi
}

make_directories () {
	sudo mkdir -p "/app/onlyoffice/setup";

	sudo mkdir -p "/app/onlyoffice/DocumentServer/data";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/FileConverterService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/CoAuthoringService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/DocService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/SpellCheckerService";
	sudo mkdir -p "/app/onlyoffice/DocumentServer/logs/documentserver/LibreOfficeService";

	sudo mkdir -p "/app/onlyoffice/MailServer/data/certs";
	sudo mkdir -p "/app/onlyoffice/MailServer/logs";
	sudo mkdir -p "/app/onlyoffice/MailServer/mysql";

	sudo mkdir -p "/app/onlyoffice/CommunityServer/data";
	sudo mkdir -p "/app/onlyoffice/CommunityServer/logs";
	sudo mkdir -p "/app/onlyoffice/CommunityServer/mysql";

	sudo mkdir -p "/app/onlyoffice/ControlPanel/data";
	sudo mkdir -p "/app/onlyoffice/ControlPanel/logs";
	sudo mkdir -p "/app/onlyoffice/ControlPanel/mysql";

	sudo chmod 777 /app -R
}

copy_license () {
	if [[ -n "${LICENSE_FILE_PATH}" ]]; then

		if ! file_exists "${LICENSE_FILE_PATH}"; then
			echo "License file is not exist";
			exit 0;
		fi

		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/DocumentServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/MailServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/CommunityServer/data/license.lic";
		cp "${LICENSE_FILE_PATH}" "/app/onlyoffice/ControlPanel/data/license.lic";

	fi
}

get_available_version () {
	if [[ -z "$1" ]]; then
		echo "image name is empty";
		exit 0;
	fi

	if ! command_exists curl ; then
		install_curl;
	fi

	RUN_COMMAND="curl -s https://registry.hub.docker.com/v1/repositories/$1/tags";

	if [[ -n ${EMAIL} && -n ${PASSWORD} ]]; then
		RUN_COMMAND="$RUN_COMMAND --basic -u $EMAIL:$PASSWORD";
	fi

	listVersion=$(${RUN_COMMAND});

	if [[ $listVersion != "["* ]]; then
		echo "invalid version list";
		exit 0;
	fi

	splitListVersion=$(echo $listVersion | tr -d '[]{},:"')
	regex="[0-9]+\.[0-9]+\.[0-9]+"
	versionList=""

	for v in $splitListVersion
	do
		if [[ $v =~ $regex ]]; then
			versionList="$v,$versionList"
		fi
	done

	version=$(echo $versionList | tr ',' '\n' | sort -t. -k 1,1n -k 2,2n -k 3,3n | awk '/./{line=$0} END{print line}');

	echo "$version"
}

check_bindings () {
	if [[ -z "$1" ]]; then
		echo "container id is empty";
		exit 0;
	fi

	binds=$(sudo docker inspect --format='{{range $p,$conf:=.HostConfig.Binds}}{{$conf}};{{end}}' $1)
	volumes=$(sudo docker inspect --format='{{range $p,$conf:=.Config.Volumes}}{{$p}};{{end}}' $1)
	arrBinds=$(echo $binds | tr ";" "\n")
	arrVolumes=$(echo $volumes | tr ";" "\n")
	bindsCorrect=1

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
		exit 0;
	fi
}

install_document_server () {

	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});
    DOCUMENT_SERVER_ADDITIONAL_PORTS="";

	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $DOCUMENT_SERVER_ID;
			sudo docker stop ${DOCUMENT_SERVER_ID};
			sudo docker rm ${DOCUMENT_SERVER_ID};
		else
			echo "ONLYOFFICE DOCUMENT SERVER is already installed."
			sudo docker start ${DOCUMENT_SERVER_ID};
		fi
	fi

	if [[ -z ${DOCUMENT_VERSION} ]]; then
		DOCUMENT_VERSION=$(get_available_version "$DOCUMENT_IMAGE_NAME");
	fi

	if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
		DOCUMENT_SERVER_ADDITIONAL_PORTS="-p 80:80 -p 443:443";
	fi
	sudo docker run -i -t -d --restart=always --name ${DOCUMENT_CONTAINER_NAME} ${DOCUMENT_SERVER_ADDITIONAL_PORTS} \
	-v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data \
	-v /app/onlyoffice/DocumentServer/logs:/var/log/onlyoffice \
	${DOCUMENT_IMAGE_NAME}:${DOCUMENT_VERSION}

	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});

	if [[ -z ${DOCUMENT_SERVER_ID} ]]; then
		echo "ONLYOFFICE DOCUMENT SERVER not installed."
		exit 0;
	fi
}

install_mail_server () {
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

	MAIL_SERVER_ADDITIONAL_PORTS="";
	
	if [[ -n ${MAIL_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $MAIL_SERVER_ID;
			sudo docker stop ${MAIL_SERVER_ID};
			sudo docker rm ${MAIL_SERVER_ID};
		else
			echo "ONLYOFFICE MAIL SERVER is already installed."
			sudo docker start ${MAIL_SERVER_ID};
		fi
	fi

	if [[ -z ${MAIL_VERSION} ]]; then
		MAIL_VERSION=$(get_available_version "$MAIL_IMAGE_NAME");
	fi
		
	if [ "${USE_AS_EXTERNAL_SERVER}" == "true" ]; then
		MAIL_SERVER_ADDITIONAL_PORTS="-p 3306:3306 -p 8081:8081";
	fi
	
	RUN_COMMAND="sudo docker run --privileged -i -t -d --restart=always --name ${MAIL_CONTAINER_NAME} ${MAIL_SERVER_ADDITIONAL_PORTS} -p 25:25 -p 143:143 -p 587:587";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/data:/var/vmail";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/data/certs:/etc/pki/tls/mailserver";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/logs:/var/log";
	RUN_COMMAND="${RUN_COMMAND} -v /app/onlyoffice/MailServer/mysql:/var/lib/mysql";
	
	if [ "$UPDATE" != "true" ]; then

		if  [[ -z ${MAIL_DOMAIN_NAME} ]]; then
			echo "Please, set domain name for mail server"
			exit 0;
		fi
		
		RUN_COMMAND="${RUN_COMMAND} -h ${MAIL_DOMAIN_NAME} ${MAIL_IMAGE_NAME}:${MAIL_VERSION}";
	else
		RUN_COMMAND="${RUN_COMMAND} ${MAIL_IMAGE_NAME}:${MAIL_VERSION}";
	fi

	${RUN_COMMAND};
	
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});

	if [[ -z ${MAIL_SERVER_ID} ]]; then
		echo "ONLYOFFICE MAIL SERVER not installed."
		exit 0;
	fi
}

install_controlpanel () {
	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	CONTROLPANEL_ADDITIONS_PARAMS="";
	
	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $CONTROL_PANEL_ID;
			OLD_CONTROLPANEL_CONTAINER_NAME="${CONTROLPANEL_CONTAINER_NAME}_$RANDOM";
			sudo docker rename ${CONTROLPANEL_CONTAINER_NAME} ${OLD_CONTROLPANEL_CONTAINER_NAME};
		else
			echo "ONLYOFFICE CONTROL PANEL is already installed."
			sudo docker start ${CONTROL_PANEL_ID};
		fi
	fi

	if [[ -z ${CONTROLPANEL_VERSION} ]]; then
		CONTROLPANEL_VERSION=$(get_available_version "$CONTROLPANEL_IMAGE_NAME");
	fi

	if [[ -n ${MAIL_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e MAIL_SERVER_EXTERNAL=true";
	fi

	if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e DOCUMENT_SERVER_EXTERNAL=true";	
	fi
	
	if [[ -n ${COMMUNITY_SERVER_HOST} ]]; then
		CONTROLPANEL_ADDITIONS_PARAMS="${CONTROLPANEL_ADDITIONS_PARAMS} -e COMMUNITY_SERVER_EXTERNAL=true";
	fi

	 sudo docker run -i -t -d --restart=always --name ${CONTROLPANEL_CONTAINER_NAME} ${CONTROLPANEL_ADDITIONS_PARAMS} \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /app/onlyoffice/CommunityServer/data:/app/onlyoffice/CommunityServer/data \
	-v /app/onlyoffice/DocumentServer/data:/app/onlyoffice/DocumentServer/data \
	-v /app/onlyoffice/MailServer/data:/app/onlyoffice/MailServer/data \
	-v /app/onlyoffice/ControlPanel/data:/var/www/onlyoffice-controlpanel/Data \
	-v /app/onlyoffice/ControlPanel/logs:/var/log/onlyoffice-controlpanel \
	-v /app/onlyoffice/ControlPanel/mysql:/var/lib/mysql \
	 ${CONTROLPANEL_IMAGE_NAME}:${CONTROLPANEL_VERSION}

	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	if [[ -z ${CONTROL_PANEL_ID} ]]; then
		echo "ONLYOFFICE CONTROL PANEL not installed."
		exit 0;
	fi

	if [[ -n ${OLD_CONTROLPANEL_CONTAINER_NAME} ]]; then
		docker rm -f ${OLD_CONTROLPANEL_CONTAINER_NAME}
	fi
}

install_community_server () {
	COMMUNITY_PORT=80
	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});
	DOCUMENT_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${DOCUMENT_CONTAINER_NAME});
	MAIL_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${MAIL_CONTAINER_NAME});
	CONTROL_PANEL_ID=$(sudo docker inspect --format='{{.Id}}' ${CONTROLPANEL_CONTAINER_NAME});

	if [[ -n ${COMMUNITY_SERVER_ID} ]]; then
		if [ "$UPDATE" == "true" ]; then
			check_bindings $COMMUNITY_SERVER_ID;
			COMMUNITY_PORT=$(sudo docker port $COMMUNITY_SERVER_ID 80 | sed 's/.*://')
			sudo docker stop ${COMMUNITY_SERVER_ID};
			sudo docker rm ${COMMUNITY_SERVER_ID};
		else
			echo "ONLYOFFICE COMMUNITY SERVER is already installed."
			sudo docker start ${COMMUNITY_SERVER_ID};
		fi
	fi

	RUN_COMMAND="sudo docker run --name $COMMUNITY_CONTAINER_NAME -i -t -d --restart=always -p $COMMUNITY_PORT:80 -p 443:443 -p 5222:5222";

	if [[ -n ${MAIL_SERVER_HOST} ]]; then
		RUN_COMMAND="$RUN_COMMAND  -e MAIL_SERVER_DB_HOST='${MAIL_SERVER_HOST}'";
	fi

	if [[ -n ${DOCUMENT_SERVER_HOST} ]]; then
		RUN_COMMAND="$RUN_COMMAND  -e DOCUMENT_SERVER_HOST='${DOCUMENT_SERVER_HOST}'";
	fi
	
	if [[ -n ${DOCUMENT_SERVER_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $DOCUMENT_CONTAINER_NAME:document_server";
	fi

	if [[ -n ${MAIL_SERVER_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $MAIL_CONTAINER_NAME:mail_server";
	fi

	if [[ -n ${CONTROL_PANEL_ID} ]]; then
		RUN_COMMAND="$RUN_COMMAND  --link $CONTROLPANEL_CONTAINER_NAME:control_panel";
	fi

	if [[ -z ${COMMUNITY_VERSION} ]]; then
		COMMUNITY_VERSION=$(get_available_version "$COMMUNITY_IMAGE_NAME");
	fi

	RUN_COMMAND="$RUN_COMMAND -v /app/onlyoffice/CommunityServer/data:/var/www/onlyoffice/Data -v /app/onlyoffice/CommunityServer/mysql:/var/lib/mysql -v /app/onlyoffice/CommunityServer/logs:/var/log/onlyoffice $COMMUNITY_IMAGE_NAME:$COMMUNITY_VERSION";

	${RUN_COMMAND};

	COMMUNITY_SERVER_ID=$(sudo docker inspect --format='{{.Id}}' ${COMMUNITY_CONTAINER_NAME});

	if [[ -z ${COMMUNITY_SERVER_ID} ]]; then
		echo "ONLYOFFICE COMMUNITY SERVER not installed."
		exit 0;
	fi
}

pull_document_server () {

	if [[ -z ${DOCUMENT_VERSION} ]]; then
		DOCUMENT_VERSION=$(get_available_version "$DOCUMENT_IMAGE_NAME");
	fi

	sudo docker pull ${DOCUMENT_IMAGE_NAME}:${DOCUMENT_VERSION}
}

pull_mail_server () {

	if [[ -z ${MAIL_VERSION} ]]; then
		MAIL_VERSION=$(get_available_version "$MAIL_IMAGE_NAME");
	fi

	sudo docker pull ${MAIL_IMAGE_NAME}:${MAIL_VERSION}
}

pull_controlpanel () {

	if [[ -z ${CONTROLPANEL_VERSION} ]]; then
		CONTROLPANEL_VERSION=$(get_available_version "$CONTROLPANEL_IMAGE_NAME");
	fi

	sudo docker pull ${CONTROLPANEL_IMAGE_NAME}:${CONTROLPANEL_VERSION}
}

pull_community_server () {

	if [[ -z ${COMMUNITY_VERSION} ]]; then
		COMMUNITY_VERSION=$(get_available_version "$COMMUNITY_IMAGE_NAME");
	fi

	sudo docker pull ${COMMUNITY_IMAGE_NAME}:${COMMUNITY_VERSION}
}

start_installation () {
	root_checking

	if ! command_exists sudo ; then
		install_sudo;
	fi

	get_os_info

	check_kernel

	if [ "$UPDATE" != "true" ]; then
		check_ports
	fi

	if ! command_exists docker ; then
		install_docker;
	fi

	docker_login

	make_directories

	copy_license

	if [ "$INSTALL_DOCUMENT_SERVER" == "true" ]; then
		install_document_server
	elif [ "$PULL_DOCUMENT_SERVER" == "true" ]; then
		pull_document_server
	fi

	if [ "$INSTALL_MAIL_SERVER" == "true" ]; then
		install_mail_server
	elif [ "$PULL_MAIL_SERVER" == "true" ]; then
		pull_mail_server
	fi

	if [ "$INSTALL_CONTROLPANEL" == "true" ]; then
		install_controlpanel
	elif [ "$PULL_CONTROLPANEL" == "true" ]; then
		pull_controlpanel
	fi

	if [ "$INSTALL_COMMUNITY_SERVER" == "true" ]; then
		install_community_server
	elif [ "$PULL_COMMUNITY_SERVER" == "true" ]; then
		pull_community_server
	fi

	echo "Installation complete"
	exit 0;
}



start_installation