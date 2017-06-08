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
        



#### 1. Update your server
It is good practice to periodically update system files
    
    sudo apt-get update
    
#### 2. Running Atlantis

##### A. Start a screen session
Screen sessions are persistent SSH session that can be checked from multiple computers
These commands leave the instance on the SSH session in the other computer still attached 
You can then log in and work can then be done as if back on the original terminal you began on for the task

    screen -S session_name
    
> for example screen -S atlantis_session

The following commands are useful to manage screens

To list open screens
    
    screen -ls

To restore a screen

    screen -r session_name
    
To switch to main screen

    CTRL + a + d
    
To kill a screen

    exit

##### B. Run Atlantis

Switch to Atlantis run directory, in this example running from Dropbox

    cd /Dropbox/mydirectory

Check the new executable is here

    ls -R |grep atlantis

Convert all ascii files in the current directory to linux file format

    flip -uv *

Give sh bash file executable status

    chmod +x atlantis_model_run1.sh

Run bash file

    sh ./atlantis_model_run1.sh


#to rename file
#mv gom_1980.sh.txt gom_1980.sh


#### 3. OPTIONAL. Install eclipse development environment for Linux

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

