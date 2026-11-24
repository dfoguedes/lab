
echo "cleaning old namespaces..."
ip -all netns delete 2>/dev/null
iptables -P FORWARD ACCEPT
sysctl -w net.bridge.bridge-nf-call-iptables=0 > /dev/null 2>&1

create_bridge(){
  local nsname="$1"
  local ifname="$2"

  ip netns add ${nsname}
  echo "creating bridge ${nsname}/${ifname}"
  ip netns exec ${nsname} ip link set lo up
  # Create the bridge device inside the namespace
  ip netns exec ${nsname} ip link add name ${ifname} type bridge
  ip netns exec ${nsname} ip link set ${ifname} up
  ip netns exec ${nsname} ip link set ${ifname} type bridge vlan_filtering 1

}

create_end_host(){
    local host_nsname="$1"
    local host_ifname="$1"
    local bridge_nsname="$3"
    local bridge_ifname="$4"
    local bridge_peer_ifname="$5" 
    local vlan_id="$6"

    ip netns add ${host_nsname}
    ip netns exec ${host_nsname} ip link set lo up
    
    # Create Veth Pair
    ip link add ${host_ifname} netns ${host_nsname} type veth peer name ${bridge_peer_ifname} netns ${bridge_nsname}
    
    ip netns exec ${host_nsname} ip link set ${host_ifname} up
    ip netns exec ${bridge_nsname} ip link set ${bridge_peer_ifname} up

    ip netns exec ${bridge_nsname} ip link set ${bridge_peer_ifname} master ${bridge_ifname}

    ip netns exec ${bridge_nsname} bridge vlan del dev ${bridge_peer_ifname} vid 1
    ip netns exec ${bridge_nsname} bridge vlan add dev ${bridge_peer_ifname} vid ${vlan_id}
}

create_bridge bridge1 br1

create_end_host host1 v-host1 bridge1 br1 v-peer1 10
create_end_host host2 v-host2 bridge1 br1 v-peer2 20
