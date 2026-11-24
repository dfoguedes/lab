#!/bin/bash

echo "Creating networking namespaces..."
ip netns add r1 
ip netns add r2 

echo "Creating veth pair..."
ip link add veth-r1 type veth peer name veth-r2

echo "Assign veth pair to the netns..."

ip link set veth-r1 netns r1
ip link set veth-r2 netns r2 



echo "Assign ip addresses to the veth...."

ip netns exec r1 ip addr add 192.255.255.1/24 dev veth-r1
ip netns exec r1 ip link set veth-r1 up
ip netns exec r2 ip addr add 192.255.255.2/24 dev veth-r2
ip netns exec r2 ip link set veth-r2 up


echo "Creating folders for each namespace individually..."

mkdir -p /etc/frr/{r1,r2}

cp /etc/frr/daemons /etc/frr/r1/daemons
cp /etc/frr/daemons /etc/frr/r2/daemons

cp /etc/frr/frr.conf /etc/frr/r1/frr.conf
cp /etc/frr/frr.conf /etc/frr/r2/frr.conf

echo "Done."
