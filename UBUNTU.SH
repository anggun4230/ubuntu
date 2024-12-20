#!/bin/bash

 .d88888b. 88888888888  .d88888b.  888b     d888        d8888  .d8888b. 8888888 
d88P" "Y88b    888     d88P" "Y88b 8888b   d8888       d88888 d88P  Y88b  888   
888     888    888     888     888 88888b.d88888      d88P888 Y88b.       888   
888     888    888     888     888 888Y88888P888     d88P 888  "Y888b.    888   
888     888    888     888     888 888 Y888P 888    d88P  888     "Y88b.  888   
888     888    888     888     888 888  Y8P  888   d88P   888       "888  888   
Y88b. .d88P    888     Y88b. .d88P 888   "   888  d8888888888 Y88b  d88P  888   
 "Y88888P"     888      "Y88888P"  888       888 d88P     888  "Y8888P" 8888888 
                                                                                
                                                                                
                                                                                
       d8888 888b    888  .d8888b.   .d8888b.  888     888 888b    888          
      d88888 8888b   888 d88P  Y88b d88P  Y88b 888     888 8888b   888          
     d88P888 88888b  888 888    888 888    888 888     888 88888b  888          
    d88P 888 888Y88b 888 888        888        888     888 888Y88b 888          
   d88P  888 888 Y88b888 888  88888 888  88888 888     888 888 Y88b888          
  d88P   888 888  Y88888 888    888 888    888 888     888 888  Y88888          
 d8888888888 888   Y8888 Y88b  d88P Y88b  d88P Y88b. .d88P 888   Y8888          
d88P     888 888    Y888  "Y8888P88  "Y8888P88  "Y88888P"  888    Y888          
                                                                                
                                                                                
# Configure local repository to Kartolo for Ubuntu 20.04
echo "Configuring local repository to Kartolo..."

# Menyetel repository ke Kartolo
cat <<EOT > /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOT

# Update repository
apt update

# Setting up VLAN 10 on eth1 using Netplan
echo "Configuring VLAN 10 on eth1 using Netplan..."

# Konfigurasi Netplan untuk VLAN
cat <<EOT > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
    eth1:
      dhcp4: no
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.9.1/24
EOT

# Apply Netplan configuration
netplan apply

# Install DHCP server if not installed
sudo apt install -y isc-dhcp-server

# Configure DHCP server
cat <<EOT > /etc/dhcp/dhcpd.conf
subnet 192.168.9.0 netmask 255.255.255.0 {
    range 192.168.9.10 192.168.9.100;
    option routers 192.168.9.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOT

# Specify the DHCP interface
echo 'INTERFACESv4="eth1.10"' > /etc/default/isc-dhcp-server

# Restart DHCP server
systemctl restart isc-dhcp-server
echo "DHCP server configured successfully."

# Enable IP forwarding
echo "Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# Configure iptables for internet sharing
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "iptables configured for NAT."

# Configure route to MikroTik network
echo "Adding route to MikroTik network..."
ip route add 192.168.200.0/24 via 192.168.9.10  # Replace 192.168.9.10 with MikroTik's IP in VLAN 10