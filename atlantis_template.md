# Current Configuration Ubuntu Server 17.04 (Zesty Zapus)
## Running as a Virtual machine instance in Azure set up to run Atlantis Ecosystem Model

### NOTE every time you start or stop the machine the IP address will change; choose a static IP if you want to change this behavior

This template sets up a base machine that can then be imaged
* See atlantis_replicate.md to replicate from template
* See atlantis_server.md for how to set up and manage your server.


##### USE THIS SCRIPT TO CREATE A TEMPLATE THAT CAN THEN BE REPLICATED TO LAUNCH MULTIPLE VIRTUAL MACHINES. FIRST CREATE THE MACHINE IN THE AZURE PORTAL. NOTE DS SERIES AND SSD AS STORAGE CANNOT BE USED WITH THESE INSTRUCTIONS, AND IS MORE EXPENSIVE. 
#
This code assumes you are running Ubuntu Server 17.04
Check the version of your OS

     lsb_release -a

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
###### Give root privileges
#
     sudo usermod data_user -G sudo

###### To change user
#   
    sudo su - data_user

## 2. Add and update packages
#### Install required packages per Atlantis wiki and utilities
##### Set as silent installs, so you can copy all lines at a time into the terminal
#
```sh
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y

    sudo apt-get install -y subversion build-essential subversion flip autoconf libnetcdf-dev libxml2-dev libproj-dev lsscsi nautilus-dropbox libudunits2-dev curl gdebi-core libssl-dev openssl

    sudo apt-get install -y libapparmor1 libv8-dev libgeos-dev libgdal-dev libproj-dev proj-bin proj-data rpm ntp ntpdate gdal-bin libproj12 libproj-dev libgdal-dev libgeo-proj4-perl python2.7 python-pip python-dev libpoppler-cpp-dev htop
 ```

##### Install missing dependencies and unused packages
        sudo apt-get -f install -y 
        sudo apt autoremove -y

## 4. Install R and R Studio Server

##### Update repository so that we get the latest R
#
```sh
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu zesty/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install r-base
```
##### Download the latest package from the RStudio website and install it with gdebi.
##### Note all VM instances are 64 bit, so you will need the 64 bit package.
###### https://www.rstudio.com/products/rstudio/download-server/# 

```sh
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
sudo gdebi --n rstudio-server-1.0.143-amd64.deb
```
Verify installation
    
    sudo rstudio-server verify-installation

You can now access your RStudio server at http://your-instance-ip:8787

> i.e. 192.241.209.245:8787

##### NOTE: When creating a VM through the Azure online portal you can select to create a Network Security group. If you do, adding permissions for TCP port 8787 from the server will not work. You have to add the permission from the portal as follows:
#

> Select a VM from the virtual machines list.

> Under settings, select Network interfaces.

> Click on the network name on the next panel.

> Select Network security group in the set of descriptors.

> Click on the Network security name group.

> Select inbound security rules, in the next panel click add and then enter
info to create a new rule. 

> Enter Name: rstudio,  Protocol: TCP, Port range: 8787. 

> Leave other fields with their default. Click ok.

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
Install R packages to common library. These 
These are some common packages for data analysis, spatial analysis, map creation, and Atlantis. Also includes packages to create markdown documents.
```sh

sudo su - -c "R --vainilla -e \"install.packages(c('shiny','sp','dismo', 'data.table', 'XML','jsonlite','httr','rvest', 'tidyverse','knitr','rgdal','proj4','ggplot2','ggthemes','ggmap','RColorBrewer','RNetCDF', 'classInt','rgeos','maps','maptools','knitcitations','plotrix','gridExtra','devtools','scales','magrittr','Hmisc','readxl','cowplot','xtable','gtable','reshape2', 'RNetCDF','doSNOW','stringr'), repos = 'http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('pdftools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github('alketh/atlantistools')\""

```
## 5. [OPTIONAL] Install Jupyter notebook
Jupyter Notebook offers an interactive web interface to many languages, including IPython and R.    
    
Check Phyton version and pip is installed

    python --version
    pip --version

Upgrade PIP and install Jupyter 

    sudo -H pip install --upgrade pip
    sudo -H pip install jupyter


To connect to Jupyter notebook use SSH (PuTTY on Windows). Specify Tunlocalhost:8888nels. Enter the IP of the VM and specify Tunnels using port 8000 or greater. Forwarded port should be 'localhost:8888'. 
Image screens for PuTTY set up are here 
https://www.digitalocean.com/community/tutorials/how-to-set-up-a-jupyter-notebook-to-run-ipython-on-ubuntu-16-04


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

## 6. Deprovison user
###### Required before generalizing machine
##### in SSH window
#
    sudo waagent -deprovision+user
    
Then exit the VM

    exit
    
## 7. Create image template
#### Following https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-capture-image/
#
##### The following steps assume you already have installed Azure Command Line tools (Azure CLI)
##### The Azure Command Line interface tools are needed to manage virtual machines; this is a OS-independent library. These tools are already installed in the virtual machine named VM manager that can be called up from the Azure portal
If not installed, the Azure CLI is available from https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/   
Install Node.js first available from https://nodejs.org/en/download/package-manager/

    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install azure-cli -g
    
If you get error messages then install missing dependencies

    sudo apt-get -f install
    
Log into the Azure account. Follow the prompts, you will be directed to open a browser 

    azure login
 
 Switch to Resource Manager mode
 
    azure config mode arm

##### Once Azure CLI is installed continue here 

##### Stop the VM which you already deprovisioned 
#
    azure vm deallocate -g <your-resource-group-name> -n <your-virtual-machine-name>
    
> for example azure vm deallocate -g 'Datascience' -n 'Datasciencemachine'

##### Generalize the VM with the following command:

    azure vm generalize -g <your-resource-group-name> -n <your-virtual-machine-name>

> for example azure vm generalize -g 'Datascience' -n 'Datasciencemachine'

##### Now capture the image and a local file template
#
    azure vm capture <your-resource-group-name> <your-virtual-machine-name> <your-vhd-name-prefix> -t <path-to-your-template-file-name.json>

where the vhd name prefix is the prefix taken from the uri of the image, which can be found by searching for blobs in the Vm storage using the Azure Portal, in the system container similar to https://xxxxxxxxxxxxxx.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/<your-vhd-name-prefix>-osDisk.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.vhd.

> for example azure vm capture 'Datascience' 'Datasciencemachine' lastname -t azurevmlastnametemplate01.json

This command creates a generalized OS image, using the VHD name prefix you specify for the VM disks. The image VHD files get created by default in the same storage account that the original VM used. (The VHDs for any new VMs you create from the image will be stored in the same account.) The -t option creates a local JSON file template you can use to create a new VM from the image.

The json file will be stored in the VM and the storage account. To find the location of an image, open the JSON file template. In the storageProfile, find the uri of the image located in the system container. For example, the uri of the OS disk image is similar to https://xxxxxxxxxxxxxx.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/<your-vhd-name-prefix>-osDisk.xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.vhd.
