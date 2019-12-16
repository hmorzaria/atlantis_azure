#!/bin/bash

echo "This script expects Ubuntu Server 18.04 (Bionic Beaver)"
echo "Will install all dependencies, libraries, Rstudio and needed packages to run Atlantis and analyze output"

sudo timedatectl set-timezone America/Los_Angeles

sudo apt-get update -y
sudo apt-get dist-upgrade -y

sudo apt-get -y --no-install-recommends install \
    autoconf \
    automake \
    curl \
    gdal-bin \
    flip \
    libcairo2 \
    libcairo2-dev \
    libapparmor1 \
    libhdf5-dev \
    libnetcdf-dev \
    libgdal-dev \
    libudunits2-dev \
    libxml2-dev \
    libproj-dev \
    libproj12 \
    libssl-dev \
    libv8-dev \
    libgeos-dev \
    libgeo-proj4-perl \
    libgeos++-dev \
    libglu1-mesa-dev \
    libpoppler-cpp-dev \
    libprotobuf-dev \
    libproj-dev \
    librsvg2-dev \
    libx11-dev \
    lsscsi \
    openjdk-8-jdk \
    python2.7 \
    python-pip \
    python-dev \
    proj-bin \
    proj-data \
    protobuf-compiler \
    htop \
    openssl \
    rpm \
    mesa-common-dev \
    netcdf-bin \
    ntp \
    ntpdate \
    subversion \
    texlive-latex-extra \
    nco \
    cdo
    
sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
sudo apt install gdal-bin -y
   
sudo add-apt-repository -y ppa:opencpu/jq
sudo apt-get update -qq
sudo apt-get install libjq-dev -y
sudo apt install python-gdal python3-gdal -y
    
sudo apt-get -f install -y # missing dependencies
sudo apt autoremove -y #unused packages
       
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'

sudo sh -c 'echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list'
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -
sudo apt-get update -qq
sudo apt-get -y install r-base

echo "Install R studio" 

sudo apt-get install -y gdebi-core
wget https://download2.rstudio.org/rstudio-server-1.1.456-amd64.deb
sudo gdebi rstudio-server-1.1.456-amd64.deb --n

echo "Install R packages"

sudo su - -c "R --vainilla -e \"install.packages(c( \
    'classInt', \
    'cowplot', \
    'digest', \
    'data.table', \
    'devtools', \
    'dismo', \
    'fields', \
    'futures', \
    'ggthemes', \
    'httr', \
    'Hmisc', \
    'jsonlite', \
    'maps', \
    'maptools', \
    'parallel', \
    'proj4', \
    'plotrix', \
    'gridExtra', \
    'raster', \
    'readxl', \
    'readr', \
    'rgdal', \
    'rgeos', \
    'rvest', \
    'RNetCDF', \
    'RColorBrewer', \
    'raster', \
    'tidyverse', \
    'stringr', \
    'stringi', \
    'sp', \
    'XML'), \
    dependencies = TRUE, repos = 'http://cran.rstudio.com/')\""
  
sudo su - -c "R -e \"devtools::install_github('jporobicg/shinyrAtlantis')\""
sudo su - -c "R -e \"devtools::install_github('Atlantis-Ecosystem-Model/ReactiveAtlantis')\""
sudo su - -c "R -e \"devtools::install_github('Azure/rAzureBatch')\""
sudo su - -c "R -e \"devtools::install_github('Azure/doAzureParallel')\""

echo "Install AzCopy" 

sudo apt-get -y install rsync wget
wget -O azcopy.tar.gz https://aka.ms/downloadazcopylinuxrhel6
tar -xzf azcopy.tar.gz
sudo ./install.sh
sudo rm -Rf azcopy* install.sh
    
if [ -d $HOME/bin ]; then
PATH=$PATH:$HOME/bin
fi
