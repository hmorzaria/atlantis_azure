# Current Configuration Ubuntu Server 18.04 (Bionic Beaver)
## This script details how to create a Virtual machine (instance) directly in the resource panel (Azure Portal)
## For use in Atlantis simulations
### Does not use a template
 NOTE DS SERIES AND SSD AS STORAGE CANNOT BE USED WITH THESE INSTRUCTIONS, AND IS MORE EXPENSIVE. 
##
Check the version of your OS

     lsb_release -a

## 1. Set current time zone and users
##### Time zone
#
    sudo timedatectl set-timezone America/Los_Angeles

To list all possible zones
    
    timedatectl list-timezones


##### Add new user (optional)
Rstudio often requires the password to be reset
Will need input for password
``` sh
sudo adduser data_user
sudo passwd data_user 
sudo usermod data_user -G sudo # gives root privileges
sudo su - data_user # change user
```

## 2. Add and update packages
#### Install required packages per Atlantis wiki and utilities
##### Silent installs, copy in blocks
#
```sh
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y

    sudo apt-get install -y subversion build-essential subversion flip autoconf libnetcdf-dev libxml2-dev libproj-dev lsscsi cdo nco libudunits2-dev curl gdebi-core libssl-dev openssl libapparmor1 libv8-dev libgeos-dev libgdal-dev libproj-dev proj-bin proj-data rpm ntp ntpdate gdal-bin libproj12 libproj-dev libgdal-dev libgeo-proj4-perl libgeos++-dev python2.7 python-pip python-dev libpoppler-cpp-dev htop libprotobuf-dev protobuf-compiler librsvg2-dev libx11-dev mesa-common-dev libglu1-mesa-dev texlive-latex-extra libcairo2 libcairo2-dev netcdf-bin
    
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y
    
    sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
    sudo apt install gdal-bin python-gdal python3-gdal
    
    sudo add-apt-repository -y ppa:opencpu/jq
    sudo apt-get update
    sudo apt-get install libjq-dev -y
    
    sudo apt-get -f install -y # missing dependencies
    sudo apt autoremove -y #unused packages
```        

## 4. Install R and R Studio Server

##### Update repository so that we get the latest R
#
```sh

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

sudo sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list'
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
wget https://download2.rstudio.org/rstudio-server-1.1.456-amd64.deb
sudo gdebi rstudio-server-1.1.456-amd64.deb

```
Verify installation
    
    sudo rstudio-server verify-installation

You can now access your RStudio server at http://your-instance-ip:8787

> i.e. 192.241.209.245:8787

##### Obtain r packages
Install R packages to common library. These 
These are some common packages for data analysis, spatial analysis, map creation, and Atlantis. Also includes packages to create markdown documents.
```sh

sudo su - -c "R --vainilla -e \"install.packages(c('tidyverse','sp','dismo', 'data.table', 'XML','jsonlite','httr','rvest', 'knitr','rgdal','proj4','ggthemes','ggmap','RColorBrewer','RNetCDF','readr', 'classInt','rgeos','maps','maptools','knitcitations','plotrix','gridExtra',
'devtools','scales','magrittr','Hmisc','readxl','cowplot','xtable','gtable',
'raster','reshape2', 'RNetCDF','doSNOW','stringr','stringi','parallel','future'), repos = 'http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('pdftools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github('alketh/atlantistools')\""
sudo su - -c "R -e \"devtools::install_github('jporobicg/shinyrAtlantis')\""

```

### 5. Build Atlantis

##### Check out Atlantis code
##### Put the username and password at the end
#
    svn co https://svnserv.csiro.au/svn/ext/atlantis/Atlantis/branches/bec_dev --username yourusername --password yourpassword 

##### Compile Atlantis
##### Switch folder 
#
    cd bec_dev/atlantis
##### Build Atlantis code
#

```sh 
aclocal
autoheader
autoconf
automake -a
./configure
make
sudo make install
cd atlantismain
```


If building Atlantis does not work, switch to root user
```sh
sudo su -
```
and try again

##### check that atlantisNew.exe has been created
#
     ls -l
     
     
### 6. Install AzCopy

    wget -O azcopy.tar.gz https://aka.ms/downloadazcopylinux64
    tar -xf azcopy.tar.gz
    sudo ./install.sh
    
   
#### OPTIONAL. Install eclipse development environment for Linux

Use if for some reason you need a browser or other GUI based software 

##### Install a minimal Gnome desktop

    sudo apt-get install xorg gnome-core gnome-system-tools gnome-app-install

##### Install a Virtual Desktop using VNC
Using instructions from http://www.havetheknowhow.com/Configure-the-server/Install-VNC.html

    sudo apt-get install vnc4server

    vncserver

You'll then be prompted to create and verify a new password

Kill vnc session

    vncserver -kill :1

Open up the config file

    vim .vnc/xstartup

Edit the file as follows

> Unmask the unset SESSION_MANAGER line and masked out all the rest. We've then added the last 3 lines.

> !/bin/sh

> Uncomment the following two lines for normal desktop:

> unset SESSION_MANAGER

> exec /etc/X11/xinit/xinitrc

> [ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup

> [ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

> xsetroot -solid grey

> vncconfig -iconic &

> x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &

> x-window-manager &

> metacity &

> gnome-settings-daemon &

> gnome-panel &

