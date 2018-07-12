# Current Configuration Ubuntu Server 16.04 (Xenial)
# This script details how to create a Virtual machine (instance) directly in the resource panel (Azure Portal)
# For use in Atlantis simulations
# Not using templates
 NOTE DS SERIES AND SSD AS STORAGE CANNOT BE USED WITH THESE INSTRUCTIONS, AND IS MORE EXPENSIVE. 
#
This code assumes you are running Ubuntu Server 17.04
Check the version of your OS

     lsb_release -a

## 1. Set current time zone and users
##### Time zone
#
    sudo timedatectl set-timezone America/Los_Angeles

To list all possible zones
    
    timedatectl list-timezones


##### Add new user (optional)
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
    sudo apt-get update -y && sudo apt-get dist-upgrade -y

    sudo apt-get install -y subversion build-essential subversion flip autoconf libnetcdf-dev libxml2-dev libproj-dev lsscsi libudunits2-dev curl gdebi-core libssl-dev openssl libapparmor1 libv8-dev libgeos-dev libgdal-dev libproj-dev proj-bin proj-data rpm ntp ntpdate gdal-bin libproj-dev libgdal-dev libgeos-3.6.2 libpoppler-cpp-dev htop libprotobuf-dev protobuf-compiler cdo nco
    
    sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && sudo apt install -y libgdal20 liblasclasses1
    
    sudo add-apt-repository -y ppa:opencpu/jq && sudo apt-get update && sudo apt-get install libjq-dev -y
    
    # missing dependencies and remove unused packages
    sudo apt-get -f install -y && sudo apt autoremove -y
        
## 4. Install R and R Studio Server

##### Update repository so that we get the latest R
#
```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
sudo sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list'
sudo apt-get update
sudo apt-get -y install r-base

```
##### Download the latest package from the RStudio website and install it with gdebi.
##### Note all VM instances are 64 bit, so you will need the 64 bit package.
###### https://www.rstudio.com/products/rstudio/download-server/# 

```sh
sudo apt-get install -y gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.453-amd64.deb
sudo gdebi rstudio-server-1.1.453-amd64.deb

```
Verify installation
    
    sudo rstudio-server verify-installation

You can now access your RStudio server at http://your-instance-ip:8787

> i.e. 192.241.209.245:8787

##### Obtain r packages
Install R packages to common library. These 
These are some common packages for data analysis, spatial analysis, map creation, and Atlantis. Also includes packages to create markdown documents.
```sh

sudo su - -c "R --vainilla -e \"install.packages(c('shiny','sp','dismo', 'data.table', 'XML','jsonlite','httr','rvest', 'tidyverse','knitr','rgdal','proj4','ggplot2','ggthemes','ggmap','RColorBrewer','RNetCDF','readr', 'classInt','rgeos','maps','maptools','knitcitations','plotrix','gridExtra','devtools','scales','magrittr','Hmisc','readxl','cowplot','xtable','gtable','reshape2', 'RNetCDF','doSNOW','stringr','stringi','parallel','future'), repos = 'http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('pdftools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github('alketh/atlantistools')\""

```

### 6. Build Atlantis

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

