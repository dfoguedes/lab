#!/bin/bash


if ["$EUID" -ne 0]; then
    echo "run as root"
    exit
fi

create_namespace(){
    echo "Creating linux namespace..." 
    unshare --fork --pid --mount-proc bash

}
configure_cgroup(){
    local cgroup_name="$1"
    local memory_max="100M"
    local cpu_max="50000 100000"

    echo "Configuring Cgroups v2..."
    mkdir /sys/fs/cgroup/cpu/${cgroup_name}
    echo "+cpu +memory -io" > /sys/fs/cgroup/${cgroup_name}/cgroup.subtree_control
    echo $$ > /sys/fs/cgroup/cpu/${cgroup_name}/cgroup.procs  # Automatically puts new processes in the cgroup (fork() will create a new process)
    echo "+cpu +memory -io" > /sys/fs/cgroup/<${cgroup_name}/cgroup.subtree_control
    echo ${cpu_max} > /sys/fs/cgroup/${cgroup_name}/cpu.max
    echo ${memory_max} > /sys/fs/cgroup/${cgroup_name}/memory.max
}


create_namespace
configure_cgroup cg1
