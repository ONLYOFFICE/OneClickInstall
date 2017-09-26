## ONLYOFFICE One Click Installation Overview

An ONLYOFFICE One Click Installation is used to automate the deployment process of ONLYOFFICE Community Edition using the Docker container technology.
ONLYOFFICE Community Edition is an open source software that comprises Document Server, Community Server and Mail Server,
all to resolve the collaboration issues for both small and medium-sized teams.


## How it works?

ONLYOFFICE One Click Installation service connects to a remote Linux machine via SSH (https://www.nuget.org/packages/SSH.NET/ or https://github.com/sshnet/SSH.NET) using the following provided user data: username with admin access rights, password or SSH key and the server IP address or full domain name, uploads the scripts from the 'Executables' folder and runs them:

The scripts are performing the following:

1. bash check-previous-version.sh  
checking the already existing data 

2. bash make-dir.sh 
creating the working directory /app/onlyoffice

3. bash get-os-info.sh  
getting the information about the currently used OS

4. bash check-ports.sh "80,443,5222,25,143,587"  
checking ports of the current computer

5. bash run-docker.sh "Ubuntu" "14.04" "3.13.0-36-generic" "x86_64"  
installing and running Docker

6. bash make-network.sh  
creating docker network

7. bash run-document-server.sh  
installing Document Server

8. bash run-mail-server.sh -d "domainName"  
installing Mail Server using the specified domain name

8. bash run-community-server.sh  
installing Community Server


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

If you have any problems with or questions about ONLYOFFICE One Click Installation, please visit our official forum to find answers to your questions: [dev.onlyoffice.org][1] or you can ask and answer ONLYOFFICE development questions on [Stack Overflow][2].

  [1]: http://dev.onlyoffice.org
  [2]: http://stackoverflow.com/questions/tagged/onlyoffice
