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
                                                                                                                             
                                                                                                                             
expect << EOF

spawn telnet 192.168.42.128 30015
expect "Mikrotik Login:"
send "admin\r"

expect "Password:"
send "\r"

expect ">"
send "n"

expect "new password"
send "123\r"

expect "repeat new password"
send "123\r"

expect ">"
send "/ip address add address=192.168.200.1/24 interface=ether2\r"

expect ">"
send "/ip address add address=192.168.17.2/24 interface=ether1\r"

expect ">"
send "/ip pool add name=dhcp_pool ranges=192.168.200.2-192.168.200.200\r"

expect ">"
send "/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool\r"

expect ">"
send "/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1 dns-server=8.8.8.8\r"

expect ">"
send "/ip dhcp-server enable dhcp1\r"

expect ">"
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"

expect ">"
send "/ip route add gateway=192.168.17.1\r"

expect eof

EOF

sudo systemctl restart isc-dhcp-server
sudo systemctl restart isc-dhcp-server
sudo systemctl restart isc-dhcp-server
