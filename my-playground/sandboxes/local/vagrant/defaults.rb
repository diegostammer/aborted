# -*- mode: ruby -*-
# vi: set ft=ruby :

WITH_GUI = false
USE_LTS = true

# System
NUM_OF_CPUS = 2
MEMORY_SIZE = 1024 # MB
VIDEO_MEMORY_SIZE = 64 # MB

# Network
PUB_NET_IFACE = "Realtek 8822CE Wireless LAN 802.11ac PCI-E NIC"
NET_GATEWAY = "192.168.68.1"
DNS = "[1.1.1.1, 8.8.8.8, 192.168.68.1]"
IP_1 = "192.168.68.101"
IP_2 = "192.168.68.102"
IP_3 = "192.168.68.103"
IP_4 = "192.168.68.104"
IP_5 = "192.168.68.105"
IP_6 = "192.168.68.106"
IP_7 = "192.168.68.107"
IP_8 = "192.168.68.108"
IP_9 = "192.168.68.109"
IP_10 = "192.168.68.110"

$script_initial_message = <<-'SCRIPT'
echo "==============================================================================="
echo "==                         DEPLOYMENT                                        =="
echo "==============================================================================="
echo "${TOOL} ${TOOL_VERSION} running on ${VAGRANT_BOX} with IP ${HOST_IP}"
SCRIPT