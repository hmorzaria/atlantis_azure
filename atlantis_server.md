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
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y

    sudo apt-get install -y subversion build-essential subversion flip autoconf libnetcdf-dev libxml2-dev libproj-dev lsscsi nautilus-dropbox libudunits2-dev curl gdebi-core libssl-dev openssl

    sudo apt-get install -y libapparmor1 libv8-dev libgeos-dev libgdal-dev libproj-dev proj-bin proj-data rpm ntp ntpdate gdal-bin libproj9 libproj-dev libgdal-dev libgeo-proj4-perl python2.7 python-pip python-dev libpoppler-cpp-dev htop
    sudo apt-get -f install -y # missing dependencies
    sudo apt autoremove -y #unused packages
        

## 4. Install R and R Studio Server

##### Update repository so that we get the latest R
#
```sh
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list'
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

##### Obtain r packages
Install R packages to common library. These 
These are some common packages for data analysis, spatial analysis, map creation, and Atlantis. Also includes packages to create markdown documents.
```sh

sudo su - -c "R --vainilla -e \"install.packages(c('shiny','sp','dismo', 'data.table', 'XML','jsonlite','httr','rvest', 'tidyverse','knitr','rgdal','proj4','ggplot2','ggthemes','ggmap','RColorBrewer','RNetCDF', 'classInt','rgeos','maps','maptools','knitcitations','plotrix','gridExtra','devtools','scales','magrittr','Hmisc','readxl','cowplot','xtable','gtable','reshape2', 'RNetCDF','doSNOW','stringr'), repos = 'http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('pdftools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github('alketh/atlantistools')\""

```

### 3. Install Google Drive
#### Using gdrive https://github.com/prasmussen/gdrive#downloads
```sh
sudo apt-get update
sudo wget -O gdrive https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download
sudo chmod +x gdrive
sudo cp gdrive /usr/local/bin
gdrive about 
```
##### In the last step you will be prompted for a verification code and given a url, which authenticates the user account for the drive
##### to upload folders
##### gdrive sync upload test.txt
##### see further instructions in http://linuxnewbieguide.org/?p=1078

### 4.  Install dropbox

    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    ~/.dropbox-dist/dropboxd

##### You will then see output like this
"This client is not linked to any account..."
"Please visit https://www.dropbox.com/cli_link?host_id=7d44a489aa58f285f2da0x67334d02c1 to link this machine."

* Leave the dropbox process running in the server (client not linked  message as above)
* Open a browser in your local desktop 
* Paste the URL given in the client not linked stage 
* If you get a link not found, kill the dropbox process (CTRL+C) and try again, quickly, it might require a few tries
* Enter your dropbox password if prompted
* You should then receive a message to confirm the client has been linked.
* Switch back to your other computer where the linking process is still running and after a second or two it should link!

Instructions follow http://www.dropboxwiki.com/tips-and-tricks/install-dropbox-in-an-entirely-text-based-linux-environment#Type_the_link_on_a_computer_which_has_a_browser

##### Install dropox client
#
```sh
mkdir -p ~/bin
wget -O ~/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py"
chmod +x ~/bin/dropbox.py
~/bin/dropbox.py start
```
##### Check status of dropbox
#
    ~/bin/dropbox.py status

##### Set selective sync in dropbox by telling it what folders to exclude from your dropbox account
##### Also checks that all requested folders have been excluded

[wait one minute after starting dropbox]
```sh
~/bin/dropbox.py exclude add ~/Dropbox/Myfolder1 ~/Dropbox/Myfolder2
~/bin/dropbox.py exclude list
```
##### Edit the CRONTAB file to make sure everything updates appropriately by typing the command:

   crontab -e

If prompted choose nano as editor

##### Add these lines to CRONTAB and exit using ctrl+x then return
> @reboot /home/.dropbox-dist/dropboxd

> 1 0-23/1 * * * /home/.dropbox-dist/dropboxd

> @reboot ~/bin/dropbox.py start
##### The latter of those two lines tells crontab to run the dropbox daemon on the first minute of every hour... important if the dropbox connection closes as it sometimes does.

#
##### Use if necessary to delete dropbox
#

    sudo apt-get remove dropbox; rm -rvf ~/.dropbox ~/.dropbox-dist
    rm -rv ~/Dropbox

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

