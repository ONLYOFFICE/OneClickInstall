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

CHECK_25=${1:-false}

if [ "`sudo netstat -lnp | grep ':80'`" != "" ]; then
    echo "The following ports must be open: 80"
    echo "INSTALLATION-STOP-ERROR[3]"
    exit 0;
fi


if [ "`sudo netstat -lnp | grep ':443'`" != "" ]; then
    echo "The following ports must be open: 443"
    echo "INSTALLATION-STOP-ERROR[3]"
    exit 0;
fi


if [ "${CHECK_25}" == "true" ] ; then

	if [ "`sudo netstat -lnp | grep ':25'`" != "" ]; then
		echo "The following ports must be open: 25"
		echo "INSTALLATION-STOP-ERROR[3]"
		exit 0;
	fi

fi


echo "INSTALLATION-STOP-SUCCESS"