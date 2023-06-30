# -*- mode: ruby -*-
# vi: set ft=ruby :

# Load Global Defaults
require_relative '../defaults.rb'

def virtualbox_version()
    vboxmanage = Vagrant::Util::Which.which("VBoxManage") || Vagrant::Util::Which.which("VBoxManage.exe")
    if vboxmanage != nil
        s = Vagrant::Util::Subprocess.execute(vboxmanage, '--version')
        full_version = s.stdout.strip!
        version_array = full_version.split("r")
        return version_array.first
    else
        return nil
    end
end

VIRTUALBOX_VERSION=virtualbox_version()
# VIRTUALBOX_VERSION = nil

if VIRTUALBOX_VERSION == nil
    raise "Virtual Box version not identified! Check PATH environment variable."
end

$script_guest_additions_packages = <<-'SCRIPT'
echo "###############################################################################"
echo "##               INSTALL PACKAGES FOR GUEST ADDITIONS                        ##"
echo "###############################################################################"
sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms libxt6 libxmu6
SCRIPT

$script_guest_additions_installation = <<-'SCRIPT'
echo "###############################################################################"
echo "##                  INSTALLATION OF GUEST ADDITIONS                          ##"
echo "###############################################################################"
KERN_DIR=/usr/src/kernels/`uname -r`
export KERN_DIR
wget "http://download.virtualbox.org/virtualbox/${VIRTUALBOX_VERSION}/VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso"
sudo mkdir "/media/VBoxGuestAdditions"
sudo mount -o loop,ro "VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso" "/media/VBoxGuestAdditions"
sudo sh "/media/VBoxGuestAdditions/VBoxLinuxAdditions.run"
rm "VBoxGuestAdditions_${VIRTUALBOX_VERSION}.iso"
sudo umount "/media/VBoxGuestAdditions"
sudo rmdir "/media/VBoxGuestAdditions"
SCRIPT