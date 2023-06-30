# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'open-uri'

def get_ubuntu_latest_versions
    url = 'http://cloud-images.ubuntu.com/releases/streams/v1/com.ubuntu.cloud:released:download.json'
    response = URI.open(url)
    data = JSON.parse(response.read)

    releases = data['products'].select { |product| product.start_with?('com.ubuntu.cloud:server:') }

    desired_releases = releases.select do |release|
        release_data = data['products'][release]
        release_data && release_data.key?('version') && release_data['arch'] == 'amd64'
    end

    desired_release_keys = desired_releases.map(&:first)

    latest_release = desired_release_keys.max_by do |release_key|
        version = data['products'][release_key]['version']
        version.to_i if version
    end

    latest_codename = data['products'][latest_release]['release_codename'] if latest_release && data['products'][latest_release]

    lts_releases = desired_release_keys.select do |release_key|
        release_data = data['products'][release_key]
        release_data && release_data.key?('version') && release_data['release_title'].include?('LTS')
    end

    latest_lts_release = lts_releases.max_by do |release_key|
        version = data['products'][release_key]['version']
        version.to_i if version
    end

    latest_lts_codename = data['products'][latest_lts_release]['release_codename'] if latest_lts_release && data['products'][latest_lts_release]

    latest_version = latest_codename.split(' ').first.downcase if latest_codename
    latest_lts_version = latest_lts_codename.split(' ').first.downcase if latest_lts_codename

    latest_vagrant_version = "ubuntu/#{latest_version}64"
    latest_lts_vagrant_version = "ubuntu/#{latest_lts_version}64"

    [latest_vagrant_version, latest_lts_vagrant_version]
end

latest_version, latest_lts_version = get_ubuntu_latest_versions

unless latest_version == nil
    UBUNTU_LATEST = latest_version
else
    raise "Failed to retrieve the latest Ubuntu version."
end

unless latest_lts_version == nil
    UBUNTU_LATEST_LTS = latest_lts_version
else
    raise "Failed to retrieve the latest Ubuntu LTS version."
end

$script_apt_update_upgrade = <<-'SCRIPT'
echo "###############################################################################"
echo "##                    APT UPDATE & APT UPGRADE                               ##"
echo "###############################################################################"
sudo apt update
sudo apt upgrade -y
SCRIPT

$script_ubuntu_install_gui = <<-'SCRIPT'
echo "###############################################################################"
echo "##                    INSTALL GUI                                            ##"
echo "###############################################################################"
sudo apt install slim -y
sudo apt install ubuntu-desktop -y
SCRIPT

$script_ubuntu_configure_network = <<-'SCRIPT'
echo "###############################################################################"
echo "##                    CONFIGURE NETWORK                                      ##"
echo "###############################################################################"
sudo echo "network:" > "/etc/netplan/00-installer-config.yaml"
sudo echo "  ethernets:" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "    eth1:" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "      dhcp4: no" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "      addresses:" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "        - ${NET_GATEWAY}/24" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "      routes:" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "      - to: default" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "        via: ${HOST_IP}" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "      nameservers:" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "        addresses: ${DNS}" >> "/etc/netplan/00-installer-config.yaml"
sudo echo "  version: 2" >> "/etc/netplan/00-installer-config.yaml"
sudo netplan apply
SCRIPT

$script_ubuntu_change_keyboard_layout = <<-'SCRIPT'
echo "###############################################################################"
echo "##                          CHANGE KEYBOARD LAYOUT                           ##"
echo "###############################################################################"
sed -i 's/XKBLAYOUT.*/XKBLAYOUT="br"/g' /etc/default/keyboard
SCRIPT

$script_ubuntu_user_creation = <<-'SCRIPT'
echo "###############################################################################"
echo "##                          CREATE UBUNTU USER                               ##"
echo "###############################################################################"
useradd -m ubuntu -s /bin/bash
passwd ubuntu << EOD
ubuntu
ubuntu
EOD
echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >> "/etc/sudoers"
SCRIPT