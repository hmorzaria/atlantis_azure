#!/bin/bash

echo "This script expects Ubuntu Server 18.04 (Bionic Beaver)"
echo "Will install all dependencies, libraries, Rstudio and needed packages to run Atlantis and analyze output"

sudo timedatectl set-timezone America/Los_Angeles

sudo apt-get update -y
sudo apt-get dist-upgrade -y

sudo apt-get -y --no-install-recommends install \
    autoconf \
    automake \
    libcurl4 \
    libcurl4-openssl-dev \
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

sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.2-382-amd64.deb
sudo gdebi rstudio-server-2021.09.2-382-amd64.deb

echo "Install AzCopy" 

wget -O azcopy_linux_amd64_10.14.1.tar https://aka.ms/downloadazcopy-v10-linux
tar -xzf azcopy_linux_amd64_10.14.1.tar
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

if [ -d $HOME/bin ]; then
PATH=$PATH:$HOME/bin
fi
