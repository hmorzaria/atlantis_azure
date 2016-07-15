# Create and configure VM from image from Atlantis server template
### Atlantis template created using atlantis_template.md
#### NOTE every time you start or stop the machine the IP address will change; choose a static IP if you want to change this behavior

### 1. Create new VMs from template
##### New VMs should be in same resource group as image and in same region
Regions are centralus, westus, eastus
##### It is easier to also use the same virtual network
#
##### Use these to create new network and subnet
#
     azure network vnet create <your-new-resource-group-name> <your-vnet-name> -l "region"
     azure network vnet subnet create <your-new-resource-group-name> <your-vnet-name> <your-subnet-name>
> for example: azure network vnet subnet create 'DataScience' 'DataScience' 'climateSubnet'

##### Can also just use default subnet (rather than naming one)
#
##### Create public IP 
#
     azure network public-ip create <your-new-resource-group-name> <your-ip-name> -l "region"

> for example: azure network public-ip create 'DataScience' datamodelrep3 -l "westus"
##### Create Network interface
#
     azure network nic create <your-new-resource-group-name> <your-nic-name> -k <your-subnetname> -m <your-vnet-name> -p <your-ip-name> -l "region"

> for example: azure network nic create 'DataScience' 'datanic3' -k 'default' -m 'DataScience' -p datamodelrep3 -l "westus"
##### From the output copy the nic ID
##### It will be a string similar to this.
#
> /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<your-new-resource-group-name>/providers/Microsoft.Network/networkInterfaces/<your-nic-name>

##### Need to edit the image json file 
##### Increase the last digit in the uri for the vhd
sudo nano myimage.json

##### Create new deployment
#
     azure group deployment create <your-new-resource-group-name> <your-new-deployment-name> -f <your-template-file-name.json>

> for example: azure group deployment create 'DataScience' 'deployanalysistemplate3' -f myimage.json

##### You will be prompted to supply a new VM name, the admin user name and password, and the Id of the NIC you created previously.
###### vmName
> myvmrep
###### adminUserName
myuser
###### adminPassword
password
###### NetworkID
###### Put here the nic ID
> /subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<your-new-resource-group-name>/providers/Microsoft.Network/networkInterfaces/<your-nic-name>


### 2. Install Google Drive
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

### 3.  Install dropbox

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

##### Add these two lines to CRONTAB and exit using ctrl+x then return
> @reboot /home/.dropbox-dist/dropboxd

> 1 0-23/1 * * * /home/.dropbox-dist/dropboxd

##### The latter of those two lines tells crontab to run the dropbox daemon on the first minute of every hour... important if the dropbox connection closes as it sometimes does.

##### If necessary to delete dropbox
     sudo apt-get remove dropbox; rm -rvf ~/.dropbox ~/.dropbox-dist
    rm -rv ~/Dropbox


### 4. Assign R library path

     sudo nano ~/.profile

Add the following line
> R_LIBS_USER='/home/atlantis/R/x86_64-pc-linux-gnu-library/3.3'


### 4. Clean up server

##### Cleaning up of partial package:

    sudo apt-get autoclean

##### Cleaning up of the apt cache:

    sudo apt-get clean

##### Cleaning up of any unused dependencies:

    sudo apt-get autoremove
