## ONLYOFFICE One Click Installation Overview

An ONLYOFFICE One Click Installation is used to automate the deployment process of ONLYOFFICE Free Edition using the Docker container technology.
ONLYOFFICE Free Edition is an open source software that comprises Document Server, Community Server and Mail Server,
all to resolve the collaboration issues for both small and medium-sized teams.


## How it works?

ONLYOFFICE One Click Installation service connects to a remote Linux machine via SSH (https://www.nuget.org/packages/SSH.NET/ or http://sshnet.codeplex.com/) using the following provided user data: username with admin access rights, password or SSH key and the server IP address or full domain name, uploads the scripts from the 'Executables' folder and runs them:

The scripts are performing the following:

1. bash check-previous-version.sh  
checking the already existing data 

2. bash make-dir.sh "/app/onlyoffice"  
creating the work directory (the folder all the necessary data will be copied to)

3. bash get-os-info.sh  
getting the information about the currently used OS

4. bash check-ports.sh true  
checking ports of the current computer (the **true** parameter is used to check whether port 25 for Mail Server is opened or not)

5. bash run-docker.sh "Ubuntu" "14.04" "x86_64" "3.13.0-36-generic" true  
installing and running Docker

During the installation process to the computer reboot might be required after which the scripts will continue to run. To indicate that the restart was done, the afterReboot (true) parameter is used.

6. bash run-document-server.sh  
installing Document Server

7. bash run-mail-server.sh "domainName"  
installing Mail Server using the specified domain name

8. bash run-community-server.sh  
installing Community Server and link it with Document Server and Mail Server, if selected


Before running each script two commands need to be executed: 

chmod +x scriptPath  
sed -i 's/\r$//' scriptPath

where scriptPath is the path to the script (e.g. /app/onlyoffice/setup/tools/check-ports.sh)

This is used to correct the document formatting (\n\r issues in different operating systems)


## Project Information

Official website: [http://one-click-install.onlyoffice.com](http://one-click-install.onlyoffice.com "http://one-click-install.onlyoffice.com")

Code repository: [https://github.com/ONLYOFFICE/OneClickInstall](https://github.com/ONLYOFFICE/OneClickInstall "https://github.com/ONLYOFFICE/OneClickInstall")

License: [Apache v.2.0](http://www.apache.org/licenses/LICENSE-2.0 "Apache v.2.0")

ONLYOFFICE SaaS version: [http://www.onlyoffice.com](http://www.onlyoffice.com "http://www.onlyoffice.com")

ONLYOFFICE Open Source version: [http://www.onlyoffice.org](http://onlyoffice.org "http://www.onlyoffice.org")


## User Feedback and Support

If you have any problems with or questions about this installer, please contact us through a [dev.onlyoffice.org][1].

  [1]: http://dev.onlyoffice.org
