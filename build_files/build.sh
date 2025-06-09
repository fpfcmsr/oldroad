#!/bin/bash

set -ouex pipefail

#' /opt`, `/usr/local`, `/mnt`, `/root` home, `/media`, + few others are symlinked to /var
# see and example below for installations that need to write to these directories

#install packages for dolphin shortcuts
#dnf5 -y install jpegoptim optipng pandoc qpdf recoll  xclip foremost perl-Image-ExifTool rdfind rhash testdisk expect

# btrfs assistant
#dnf5 -y install btrfs-assistant

#for phone integration via usb
#dnf5 -y copr enable zeno/scrcpy
#dnf5 -y install scrcpy 
#dnf5 -y copr disable zeno/scrcpy

#copr install webapp manager from bazzite
#dnf5 -y copr enable bazzite-org/webapp-manager
#dnf5 -y install webapp-manager 
#dnf5 -y copr disable bazzite-org/webapp-manager

#copr install python validity for fingerprint reader
dnf5 -y copr enable sneexy/python-validity
dnf5 -y install open-fprintd fprintd-clients fprintd-clients-pam python3-validity
dnf5 -y copr disable sneexy/python-validity

#copr for acpi-call for powering off nvidia gpu under nouveau
#dnf5 -y copr enable cr7pt0gr4ph7/acpi_call 
#dnf5 -y install acpi_call-kmod acpi_call-kmod-common
#dnf5 -y copr disable cr7pt0gr4ph7/acpi_call 

ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && ln -sf /etc/alternatives/ld /usr/bin/ld

# Récupération des variables cibles
ARCH=$(rpm -E '%_arch')
KERNEL=$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
RELEASE=$(rpm -E '%fedora')

echo "Kernel module folder :"
ls /usr/lib/modules/

echo "Kernel SRC folder :"
ls /usr/src/kernels/

echo "LD path :"
find /usr -name ld
which ld

# Cloner le dépôt
git clone https://github.com/nix-community/acpi_call.git /tmp/acpi_call

# Aller dans le répertoire cloné
cd /tmp/acpi_call

# Compiler le module pour le noyau cible
make -C /usr/src/kernels/${KERNEL} M=$(pwd) modules

# Vérifier si la compilation a réussi
if [ $? -ne 0 ]; then
    echo "Erreur lors de la compilation du module acpi_call."
    exit 1
fi

# Déplacer le module au bon emplacement
mkdir -p /usr/lib/modules/${KERNEL}/extra/acpi_call/
mv acpi_call.ko /usr/lib/modules/${KERNEL}/extra/acpi_call/


# Mettre à jour les dépendances du module pour le noyau spécifié
depmod -a ${KERNEL}

# Afficher un message de confirmation
echo "Le module acpi_call a été compilé et déplacé avec succès pour le noyau ${KERNEL}."


#try to use bbswitch
git clone https://github.com/Bumblebee-Project/bbswitch.git /tmp/bbswitch
cd /tmp/bbswitch
make -C /usr/src/kernels/${KERNEL} M=$(pwd) modules

mkdir -p /usr/lib/modules/${KERNEL}/extra/bbswitch/
mv bbswitch.ko /usr/lib/modules/${KERNEL}/extra/bbswitch/
depmod -a ${KERNEL}

#install specific brother printers
rm /opt
mkdir /opt
mkdir /tmp/rpms
curl --retry 3 -Lo /tmp/rpms/mfcl2710dwpdrv-4.0.0-1.i386.rpm "https://download.brother.com/welcome/dlf103525/mfcl2710dwpdrv-4.0.0-1.i386.rpm"
curl --retry 3 -Lo /tmp/rpms/brscan4-0.4.11-1.x86_64.rpm "https://download.brother.com/welcome/dlf105203/brscan4-0.4.11-1.x86_64.rpm"
curl --retry 3 -Lo /tmp/rpms/brscan-skey-0.3.2-0.x86_64.rpm "https://download.brother.com/welcome/dlf006650/brscan-skey-0.3.2-0.x86_64.rpm"
curl --retry 3 -Lo /tmp/rpms/brother-udev-rule-type1-1.0.2-0.noarch.rpm "https://download.brother.com/welcome/dlf103900/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
curl --retry 3 -Lo /tmp/rpms/brmfcfaxdrv-2.0.2-1.x86_64.rpm "https://download.brother.com/welcome/dlf105190/brmfcfaxdrv-2.0.2-1.x86_64.rpm"

# get and download / install bitwarden rpm
#URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases | jq -r 'first(.[] | .assets[]? | select(.browser_download_url | endswith(".rpm")) | .browser_download_url)')
#echo "Downloading Bitwarden from $URL"
#curl -sL -o /tmp/rpms/bitwarden-latest.rpm "$URL"

#install all the downloaded rpms
dnf5 install -y /tmp/rpms/*
mv /opt /usr/share/factory
ln -s /var/opt /opt

#microsoft fonts install
dnf5 -y install mscore-fonts-all xorg-x11-font-utils cabextract fontconfig
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

