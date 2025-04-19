#!/bin/bash

# do the interactive stuff first
sudo authselect enable-feature with-fingerprint
sudo authselect apply-changes


# then do the stuff that can be done unsupervised

sudo ujust dx-group


mkdir /home/$user/Documents/SYSTEM-EDITS
git clone https://github.com/cfgnunes/nautilus-scripts.git /home/$user/Documents/SYSTEM-EDITS
cp nautilus-install.sh /home/$user/Documents/SYSTEM-EDITS/nautilus-scripts
sudo bash nautilus-install.sh

# edit gpu switching config to enable seamless hotplug
sudo rm /etc/supergfxd.conf
sudo touch /etc/supergfxd.conf
sudo echo '{
“mode”: “Integrated”,
“vfio_enable”: true,
“vfio_save”: false,
“always_reboot”: false,
“no_logind”: true,
“logout_timeout_s”: 60,
“hotplug_type”: “Asus”
}' >> /etc/supergfxd.conf
