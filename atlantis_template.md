# Configuration Ubuntu Server 16.04 LTS
# Running as a Virtual machine instance in Azure 
# Set up to run Atlantis Ecosystem Model

### NOTE every time you start or stop the machine the IP address will change; choose a static IP if you want to change this behavior

This template sets up a base machine that can then be imaged
* See set_up_VM manager.txt for how to image
* See Set_up_data_science_replicate.txt for how to set up user account (dropbox, google drive)


##### IN THE AZURE PORTAL STOP VM AND CHANGE THE OS DISK SIZE AND SAVE
##### THE DISK WILL UPDATE AND RESIZE AUTOMATICALLY, THEN RESTART MACHINE
##### IF YOU DO ADD A DATA DISK THEN FOLLOW INSTRUCTIONS FOR ATTACHING HD
##### IF USING SSD DO NOT NEED TO ADD SWAP
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
##### Note all VM instances are 64 bit, so you’ll need the 64 bit package.
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

### 5. Clean up server
##### Cleaning up of partial package
#
    sudo apt-get autoclean

##### Cleaning up of the apt cache
#
    sudo apt-get clean

##### Cleaning up of any unused dependencies
#
    sudo apt-get autoremove

##### 6. Deprovison user
###### Required before generalizing machine
##### in SSH window
#
    sudo waagent -deprovision+user
    exit
