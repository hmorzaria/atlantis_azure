#!/bin/bash

echo "This script expects Ubuntu Server 18.04.06 LTS (Bionic Beaver)"
echo "Will install all dependencies, libraries, Rstudio and needed packages to run Atlantis and analyze output"

sudo timedatectl set-timezone America/Los_Angeles

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get -y --no-install-recommends install \
    autoconf \
    automake \
    build-essential \
    m4 \
    gfortran \
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
    python3-pip \
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
       
# update indices
sudo apt update -qq
# install two helper packages we need
sudo apt install --no-install-recommends software-properties-common dirmngr -y
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: 298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y

sudo apt install --no-install-recommends r-base -y
sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+ -y

sudo apt install --no-install-recommends r-cran-tidyverse -y

echo "Install R studio" 

sudo apt-get install gdebi-core -y
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.2-485-amd64.deb
sudo gdebi rstudio-server-2022.02.2-485-amd64.deb

echo "Install AzCopy" 

wget -O azcopy_linux_amd64_10.14.1.tar https://aka.ms/downloadazcopy-v10-linux
tar -xzf azcopy_linux_amd64_10.14.1.tar
sudo cp ./azcopy_linux_amd64_*/azcopy /usr/bin/

if [ -d $HOME/bin ]; then
PATH=$PATH:$HOME/bin
fi
