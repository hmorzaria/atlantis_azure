# Create and configure VM from image from Atlantis server template
### Atlantis template created using atlantis_template.md
#### NOTE every time you start or stop the machine the IP address will change; choose a static IP if you want to change this behavior

### The following steps assume you already have installed Azure Command Line tools (Azure CLI)
##### No need to follow these steps if you are working from the VM manager machine
##### The Azure Command Line interface tools are needed to manage virtual machines; this is a OS-independent library. These tools are already installed in the virtual machine named VM manager that can be called up from the Azure portal

The Azure CLI is available from https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/   
Install Node.js first available from https://nodejs.org/en/download/package-manager/

    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
    
    sudo apt-get install -y nodejs
    sudo npm install azure-cli -g
Log into the Azure account

    azure login
 
 Switch to Resource Manager mode
 
    azure config mode arm

### 1. Create new VMs from template
##### ***PLEASE FOLLOW THE USE OF SINGLE QUOTATION MARKS IN THE EXAMPLES***
#
#
##### New VMs should be in same resource group as the image template and in same region
##### Also always use the same virtual network and default subnet
Regions are centralus, westus, eastus

##### OPTIONAL:  use these to create new network and subnet
#
     azure network vnet create <your-new-resource-group-name> <your-vnet-name> -l "region"
     azure network vnet subnet create <your-new-resource-group-name> <your-vnet-name> <your-subnet-name>
> for example: azure network vnet subnet create 'DataScience' 'DataScience' 'default'

##### A. Create public IP 
#
     azure network public-ip create <your-new-resource-group-name> <your-ip-name> -l "region"

> for example: azure network public-ip create 'DataScience' datamodelrep4 -l "westus"
##### B. Create network interface (NIC)

###### Every VM requires a new NIC otherwise you will get an error
#
     azure network nic create <your-new-resource-group-name> <your-nic-name> -k <your-subnetname> -m <your-vnet-name> -p <your-ip-name> -l "region"

> for example: azure network nic create 'DataScience' 'datanic4' -k 'default' -m 'DataScience' -p datamodelrep4 -l "westus"

Show the NIC ID

##### C. From the output copy the nic ID

    azure network nic show <your-new-resource-group-name> <your-nic-name>

> Scroll up to the nic ID
> Copy starting in '/subscriptions'
> ###### MAKE SURE YOU ARE COPYING THE RIGHT LINE!
It should look like this (Note the networkInterfaces/
> data:  Id  : /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<your-new-resource-group-name>/providers/Microsoft.Network/networkInterfaces/<your-nic-name>

##### D. Copy the image json file and edit the NEW version
###### Increase the last digit in the uri for the vhd

> Enter the editor

> Scroll down or rigth until you find a string that starts "vhd": {     "uri"
> Example:
> https://datamodelrep3.blob.core.windows.net/vmcontainer9d9ea85c-dd89-4458-a4e1-d6b2c3c2bee1/osDisk.5d4ea85c-dd65-4458-a4e9-d6b8c3c2bee2.vhd

> Change the last digit before the extension .vhd

#

    cp myimage.json newmyimage.json
    sudo nano newmyimage.json
    
###### To exit the editor CTRL+X
#
##### E. Create new deployment
#
Use the new json file you edited previously

     azure group deployment create <your-new-resource-group-name> <your-new-deployment-name> -f <your-template-file-name.json>

> for example: azure group deployment create 'DataScience' 'deployanalysistemplate3' -f mynewimage.json
##### The json file is the one you created when imaging your machine
#
##### F. Fill in requested fields
Supply a new VM name, the admin user name and password, and the Id of the NIC you created previously.
###### vmName
> myvmrep
###### adminUserName
myuser
###### adminPassword
password
###### NetworkID
###### Put here the nic ID
> Tne networkInterfaceID will look like:

> /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<your-new-resource-group-name>/providers/Microsoft.Network/networkInterfaces/<your-nic-name>

### 2. Set up user

Specify user password

    sudo passwd atlantis


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


### 3. Assign R library path

     sudo nano ~/.profile

Add the following line. Check if R version is correct
> R_LIBS_USER='/home/atlantis/R/x86_64-pc-linux-gnu-library/3.3.1'

### 4. Build Atlantis

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


### 5. Clean up server

##### Cleaning up of partial package:

    sudo apt-get autoclean

##### Cleaning up of the apt cache:

    sudo apt-get clean

##### Cleaning up of any unused dependencies:

    sudo apt-get autoremove

#### Download and install AzCopy
Allows upload of data to a blob storage account.
Install .Net Core first
```sh
sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list' 
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
```
```sh
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > ./microsoft-prod.list
sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/

sudo apt-get update
sudo apt-get install azcopy
```
