#!/bin/bash

# Target URL for network check
NET_HOST="google.com"
# NET_URL="http://$NET_HOST"
# Configuration files server
CONF_HOST=MAT-LEGIONPRO.local # Default: actiqClient
CONF_URL="http://$CONF_HOST:90/conf"


# Function to check network connection
check_network_connection() {
    curl --silent --head --fail "$1" > /dev/null
    return $?
}

get_ip() {
    #_ip=$(dig +short $1|head -n 1)
    _ip=$(getent ahosts "$1" | awk '{print $1; exit}') # Get IP. In case of multiple IPs it returns only one.
    echo $_ip
}

get_interface() {
    _host_ip=$(get_ip $1)
    _interf=$(ip route get $_host_ip | grep -Po '(?<=(dev ))(\S+)')  # Get the interface used to reach the host.
    echo $_interf
}

get_interface_IPs() {
    _iface_ips=$(ip addr show $1 | grep 'inet ' | awk '{print $2}' | cut -d '/' -f 1 | tr '\n' ' ' | sed 's/ $//')
    echo $_iface_ips
}

# Function to return MAC address of the interface connecting to internet
get_mac() {
    _mac=$(ip addr show $1 | grep link/ether | awk '{print $2}') 
    echo $_mac
}

get_compact_mac() {
    _compact_mac=$(echo $1 | sed s/://g)
    echo $_compact_mac
}

sanitize_config_file() {
    dos2unix -q $1                  #convert new lines in unix format
    sed -i 's/#.*$//' $1            #remove comments
    sed -i '/^[[:blank:]]*$/d' $1   #remove blank lines
    sed -i '$a\' $1        #if there is no new line at the end of the file, add one
}

# Loop to wait for network connection indefinitely
echo -n "Waiting for internet connection... "
while true; do
    check_network_connection $NET_HOST
    if [ $? -eq 0 ]; then break; fi
    sleep 2
done
echo "OK"

# Check if "actiqClient" configuration server is resolving
echo -n "Resolving config server IP... "
c_ip=$(get_ip $CONF_HOST)
if [ -n "$c_ip" ]; then
    echo "$c_ip"
else
    echo "FAILED"
fi

# Find interface used by the connection to the config server
echo -n "Finding interface used to connect to config server... "
c_iface=$(get_interface $c_ip)
if [ -n "$c_iface" ]; then
    echo "$c_iface"
else
    echo "FAILED"
fi

# Find interface used by the connection to the config server
echo -n "Finding MAC of interface $c_iface... "
c_mac=$(get_mac $c_iface)
if [ -n "$c_mac" ]; then
    echo "$c_mac"
else
    echo "FAILED"
fi

# Find IPs of the interface used by the connection to the config server
echo -n "Finding IPs of interface $c_iface... "
c_IPs=$(get_interface_IPs $c_iface)
if [ -n "$c_IPs" ]; then
    echo "$c_IPs"
else
    echo "FAILED"
fi

# Fetch  file
echo -n "Fetching hosts file... "
hosts_downloaded=$(wget -q -O thinstation.hosts "$CONF_URL/thinstation.hosts" || rm -f thinstation.hosts)
if [ -f "thinstation.hosts" ]; then
    echo "OK"
else
    echo "FAILED"
fi

# Fetch hosts file
echo -n "Fetching generic config file... " 
netconf_downloaded=$(wget -q -O thinstation.network "$CONF_URL/thinstation.network" || rm -f thinstation.network)
if [ -f "thinstation.network"  ]; then
    echo "OK"
else
    echo "FAILED"  	
fi

# Check if hosts file contains a hostname for the machine
echo -n "Checking for assigned hostname... "
new_hostname=$(grep -E "^\s*[^#]+\s+$(get_compact_mac $c_mac)" "thinstation.hosts" | awk '{print $1}')
if [ -n "$new_hostname" ]; then
    echo "$new_hostname"
else
    echo "NOT FOUND"
fi

# Fetch config file by hostname
echo -n "Fetching config file by hostname... "
config_host_fn="thinstation.conf-$new_hostname"
$(wget -q -O "$config_host_fn" $CONF_URL/$config_host_fn || rm -f $config_host_fn)
if [ -f "$config_host_fn" ]; then
    echo "OK"
else
    echo "NOT FOUND"
fi

# Fetch config file by MAC
echo -n "Fetching config file by MAC... "
config_mac_fn="thinstation.conf-$(get_compact_mac $c_mac)"
$(wget -q -O "$config_mac_fn" $CONF_URL/$config_mac_fn || rm -f $config_mac_fn)
if [ -f "$config_mac_fn" ]; then
    echo "OK"
else
    echo "NOT FOUND"
fi

echo "Loading configurations:"
if [ -f thinstation.network ]; then 
    echo "- thinstation.network -" 
    sanitize_config_file thinstation.network
    cat thinstation.network
    . thinstation.network
fi
if [ -f $config_host_fn ]; then
    echo "- $config_host_fn -"
    sanitize_config_file $config_host_fn
    cat $config_host_fn
    . $config_host_fn
fi
if [ -f $config_mac_fn ]; then 
    echo "- $config_mac_fn -"
    sanitize_config_file $config_mac_fn
    cat $config_mac_fn
    . $config_mac_fn
fi	
