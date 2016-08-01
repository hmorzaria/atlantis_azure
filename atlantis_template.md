# Configuration Ubuntu Server 16.04 LTS
## Running as a Virtual machine instance in Azure set up to run Atlantis Ecosystem Model

### NOTE every time you start or stop the machine the IP address will change; choose a static IP if you want to change this behavior

This template sets up a base machine that can then be imaged
* See set_up_VM manager.txt for how to image
* See Set_up_data_science_replicate.txt for how to set up user account (dropbox, google drive)


##### USE THIS SCRIPT TO CREATE A TEMPLATE THAT CAN THEN BE REPLICATED TO LAUNCH MULTIPLE VIRTUAL MACHINES. FIRST CREATE THE MACHINE IN THE AZURE PORTAL; THEN STOP VM AND CHANGE THE OS DISK SIZE AND SAVE. THE DISK WILL UPDATE AND RESIZE AUTOMATICALLY, THEN RESTART MACHINE. IF YOU DO ADD A DATA DISK THEN FOLLOW INSTRUCTIONS FOR ATTACHING HD (SEE ADDDISK.MD). IF USING SSD DO NOT NEED TO ADD SWAP
#

## 1. Set current time zone and users
##### Time zone
Follow command prompts after entering
#
    sudo dpkg-reconfigure tzdata

##### Add new user (optional)
Will need input for password
``` sh
sudo adduser data_user
sudo passwd data_user 
```
##### Give root privileges
#
     sudo usermod data_user -G sudo

##### To change user
#   
    sudo su - data_user


## 2. Add firewall

    sudo ufw allow ssh
    sudo ufw allow 8787/tcp

##### Enable firewall
#
    sudo ufw enable

##### Review selections
#
    sudo ufw show added

## 3. Add and update packages
##### Install required packages per Atlantis wiki and utilities
#

```sh
    sudo apt-get update 
    sudo apt-get dist-upgrade

    sudo apt-get install subversion build-essential subversion flip autoconf libnetcdf-dev libxml2-dev libproj-dev lsscsi nautilus-dropbox 
    sudo apt-get install curl gdebi-core r-base libapparmor1 libv8-dev libgeos-dev libgdal-dev libproj-dev proj-bin proj-data rpm ntp ntpdate

wget https://launchpad.net/ubuntu/+archive/primary/+files/libproj9_4.9.1-2_amd64.deb
sudo dpkg -i libproj9_4.9.1-2_amd64.deb

wget https://launchpad.net/ubuntu/+archive/primary/+files/libproj-dev_4.9.1-2_amd64.deb
sudo dpkg -i libproj-dev_4.9.1-2_amd64.deb

wget http://launchpadlibrarian.net/171885381/gdal-bin_1.10.1+dfsg-5ubuntu1_amd64.deb
sudo dpkg -i gdal-bin_1.10.1+dfsg-5ubuntu1_amd64.deb

wget http://mirrors.kernel.org/ubuntu/pool/universe/g/gdal/libgdal-dev_1.10.1+dfsg-5ubuntu1_amd64.deb
sudo dpkg -i libgdal-dev_1.10.1+dfsg-5ubuntu1_amd64.deb

wget http://mirrors.kernel.org/ubuntu/pool/universe/libg/libgeo-proj4-perl/libgeo-proj4-perl_1.05-1_amd64.deb
sudo dpkg -i libgeo-proj4-perl_1.05-1_amd64.deb

```

### Install missing dependencies
    sudo apt-get -f install

## 4. Install R Studio Server

##### Update repository so that we get the latest R
#
```sh
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install r-base
```
##### Download the latest package from the RStudio website and install it with gdebi.
##### Note all VM instances are 64 bit, so youbll need the 64 bit package.
###### https://www.rstudio.com/products/rstudio/download-server/# 

```sh
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb
sudo gdebi rstudio-server-0.99.902-amd64.deb
```

You can now access your RStudio server at http://<your-instance-ip>:8787

> i.e. 192.241.209.245:8787
##### To start and stop the server
#
```sh 
sudo rstudio-server stop
sudo rstudio-server start
```
Once installed, RStudio Server will start automatically, and will restart every time your instance is booted up.

##### configure server
##### this command will open up a text editor

    sudo nano /etc/rstudio/rsession.conf

##### add this line in the document
#  
> session-timeout-minutes=30

##### then exit  CTRL-X
#
##### Obtain r packages

```sh
sudo su - -c "R -e \"install.packages(c('shiny','sp','dismo', 'data.table', 'XML','jsonlite','graphics','plyr','dplyr','tidyr','knitr','rgdal','proj4','ggplot2','ggthemes','ggmap','RColorBrewer', 'classInt','rgeos','maps','maptools','knitcitations','plotrix','gridExtra','devtools','scales','magrittr','Hmisc','spocc','ridigbio','rvertnet','ecoengine','rbison','rgbif','rebird','readxl','taxize','sperich','cowplot','xtable','gtable','reshape2'), repos = 'http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('dplyr', repos='http://cran.rstudio.com/')\""
```

## 5. Build Atlantis

##### Check out Atlantis code
##### Put the username and password at the end
#
    svn co https://svnserv.csiro.au/svn/ext/atlantis/Atlantis/branches/bec_dev --username  --password 

##### Compile Atlantis
##### Switch folder 
#
    cd bec_dev/atlantis
##### Switch user to root and build Atlantis code
#
```sh 
sudo su -
aclocal
autoheader
autoconf
automake -a
./configure
make
sudo make install
cd atlantismain
```
##### check that atlantisNew.exe has been created
#
     ls -l

## 6. Clean up server
##### Cleaning up of partial package
#
    sudo apt-get autoclean

##### Cleaning up of the apt cache
#
    sudo apt-get clean

##### Cleaning up of any unused dependencies
#
    sudo apt-get autoremove

## 7. Deprovison user
###### Required before generalizing machine
##### in SSH window
#
    sudo waagent -deprovision+user
    exit
    
## 8. Create image template
#### Following https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-capture-image/
#
##### The following steps assume you already have installed Azure Command Line tools (Azure CLI)
##### The Azure Command Line interface tools are needed to manage virtual machines; this is a OS-independent library. These tools are already installed in the virtual machine named VM manager that can be called up from the Azure portal
If not installed, the Azure CLI is available from https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/   
Install Node.js first available from https://nodejs.org/en/download/package-manager/

    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install azure-cli -g
Log into the Azure account

    azure login
 
 Switch to Resource Manager mode
 
    azure config mode arm

##### Once Azure CLI is installed continue here 

##### Stop the VM which you already deprovisioned 
#
    azure vm deallocate -g <your-resource-group-name> -n <your-virtual-machine-name>
    
> for example azure vm deallocate -g 'Datascience' -n 'Datasciencemachine'

##### Generalize the VM with the following command:

    azure vm generalize –g <your-resource-group-name> -n <your-virtual-machine-name>

> for example azure vm generalize –g 'Datascience' -n 'Datasciencemachine'

##### Now capture the image and a local file template
#
    azure vm capture <your-resource-group-name> <your-virtual-machine-name> <your-vhd-name-prefix> -t <path-to-your-template-file-name.json>

You need to assign all images a prefix, use your lastname
> for example azure vm capture 'Datascience' 'Datasciencemachine' lastname -t azurevmlastnametemplate.json

This command creates a generalized OS image, using the VHD name prefix you specify for the VM disks. The image VHD files get created by default in the same storage account that the original VM used. (The VHDs for any new VMs you create from the image will be stored in the same account.) The -t option creates a local JSON file template you can use to create a new VM from the image.

The json file will be stored in the VM and the storage account. To find the location of an image, open the JSON file template. In the storageProfile, find the uri of the image located in the system container. For example, the uri of the OS disk image is similar to https://xxxxxxxxxxxxxx.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/<your-vhd-name-prefix>-osDisk.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.vhd.
