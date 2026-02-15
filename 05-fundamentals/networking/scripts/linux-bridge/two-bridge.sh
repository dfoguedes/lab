#!/bin/bash

# Ensure Root
if [ "$EUID" -ne 0 ]; then
    echo "You're not running as root user."
    exit 1
fi

echo "cleaning old namespaces..."
ip -all netns delete 2>/dev/null
iptables -P FORWARD ACCEPT
sysctl -w net.bridge.bridge-nf-call-iptables=0 > /dev/null 2>&1



create_bridge(){
  local nsname="$1"
  local ifname="$2"
  local gateway_ip="172.16.0.1/24"
  local bridge_root_address="10.0.0.2/24"
  local root_bridge_address="10.0.0.1/24"
  local bridge_root_int="v-bridge-root"
  local root_bridge_int="v-root-bridge"

  echo "cleaning existing interfaces..."

  ip link delete ${root_bridge_int}

  echo "creating bridge ${nsname}/${ifname}"
  ip netns add ${nsname}
  ip netns exec ${nsname} ip link set lo up
  ip netns exec ${nsname} ip link add ${ifname} type bridge
  ip netns exec ${nsname} ip addr add ${gateway_ip} dev br1
  ip netns exec ${nsname} ip link set ${ifname} up

  # Routing to internet via host machine (bridge  is inside a namespace)
  ip link add ${root_bridge_int} type veth peer name ${bridge_root_int} netns ${nsname}
  ip netns exec ${nsname} ip addr add ${bridge_root_address} dev ${bridge_root_int} 
  ip netns exec ${nsname} ip link set ${bridge_root_int} up
  
  ip addr add ${root_bridge_address} dev ${root_bridge_int}
  ip link set ${root_bridge_int} up

  # IP forwarding and nat masquerading
  ip netns exec ${nsname} ip route add default via 10.0.0.1
  sysctl -w net.ipv4.ip_forward=1 > /dev/null
  ip netns exec ${nsname} sysctl -w net.ipv4.ip_forward=1 > /dev/null
  iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o enp0s3 -j MASQUERADE

  # host
  ip route add 172.16.0.0/24 via 10.0.0.2
}

create_end_host(){
    local host_nsname="$1"
    local host_ifname="$2"
    local bridge_nsname="$3"
    local bridge_ifname="$4"
    local bridge_peer_ifname="$5"
    local host_ip="$6"
    local bridge_ip="172.16.0.1"

    echo "--- Connecting ${host_nsname} to Bridge ${bridge_ifname} ---"
    
    #  Create Host Namespace
    ip netns add ${host_nsname}
    ip netns exec ${host_nsname} ip link set lo up

    #  Create Veth Pair 
    ip link add ${host_ifname} netns ${host_nsname} type veth peer name ${bridge_peer_ifname} netns ${bridge_nsname}

    #  Bridge 
    ip netns exec ${host_nsname} ip link set ${host_ifname} up
    ip netns exec ${bridge_nsname} ip link set ${bridge_peer_ifname} up

    #  Add IP to Host
    ip netns exec ${host_nsname} ip addr add ${host_ip} dev ${host_ifname}

    #  Attach bridge-side interface to the bridge
    ip netns exec ${bridge_nsname} ip link set ${bridge_peer_ifname} master ${bridge_ifname}

    ip netns exec ${host_nsname} ip route add default via ${bridge_ip} 
    
}

connect_bridges(){
    local bridge1_ns="$1"
    local bridge1_if="$2"
    local bridge2_ns="$3"
    local bridge2_if="$4"
    local peer1_if="v-peer1"
    local peer2_if="v-peer2"
    
    echo "--- Connecting ${bridge1_ns} to ${bridge2_ns} ---"
    
    # Create Veth Pair
    ip link add ${peer1_if} netns ${bridge1_ns} type veth peer name ${peer2_if} netns ${bridge2_ns}
    
    # Set interfaces up
    ip netns exec ${bridge1_ns} ip link set ${peer1_if} up
    ip netns exec ${bridge2_ns} ip link set ${peer2_if} up
    
    # Attach bridge-side interfaces to the respective bridges
    ip netns exec ${bridge1_ns} ip link set ${peer1_if} master ${bridge1_if}
    ip netns exec ${bridge2_ns} ip link set ${peer2_if} master ${bridge2_if}

}

create_bridge bridge1 br1

create_end_host host1 eth1 bridge1 br1 v-h1 172.16.0.10/24
create_end_host host2 eth2 bridge1 br1 v-h2 172.16.0.11/24
connect_bridges bridge1 br1 bridge2 br2

echo "--- Testing Connectivity (Host1 -> Host2)..."
ip netns exec host1 ping -c 2 172.16.0.11