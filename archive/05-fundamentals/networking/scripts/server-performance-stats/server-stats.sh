#!/bin/bash

# SCRIPT: server-stats.sh
# AUTHOR: Diogo Guedes
# DATE: 2025-06-18
# PURPOSE: Gathers and displays key server performance metrics.
# USAGE: 
#   ./server-stats.sh
#   ./server-stats.sh > server_stats_$(date +%F).log

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error.
# The return value of a pipeline is the status of the last command to exit with a non-zero status.
set -euo pipefail

# --- GATHER SYSTEM STATISTICS ---

# Get total CPU usage. top is run twice (-n2) for an accurate reading.
# The idle CPU % is in the 8th column ($8), so we subtract it from 100.
TOTAL_CPU_USAGE=$(top -bn2 | grep "Cpu(s)" | tail -n1 | awk '{print 100 - $8}')

# Get memory usage from the 'free' command.
TOTAL_MEMORY_USAGE=$(free -mh | awk 'NR==2 {print $3}')

# Get disk usage for the root partition (/).
TOTAL_DISK_USAGE=$(df -h | awk '$NF=="/"{print $5}')

# Get the top 5 processes by CPU usage.
TOP_5_CPU_PROCESSES=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)

# Get the top 5 processes by Memory usage.
TOP_5_MEM_PROCESSES=$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6)

# Get OS and kernel version.
OS=$(uname -a)

# Get system uptime g
UPTIME=$(uptime -p)

# Get the number of currently logged-in users.
USERS=$(who | wc -l)


# --- DISPLAY STATISTICS ---

echo "===== SERVER STATS ====="
echo "OS Version: $OS"
echo "Uptime: $UPTIME"
echo "Logged-in users: $USERS"

echo -e "\nCPU Usage: ${TOTAL_CPU_USAGE}%"
echo "Memory Usage: $TOTAL_MEMORY_USAGE"
echo "Disk Usage: $TOTAL_DISK_USAGE"
 
echo -e "\nTop 5 CPU-consuming processes:"
echo "$TOP_5_CPU_PROCESSES"

echo -e "\nTop 5 Memory-consuming processes:"
echo "$TOP_5_MEM_PROCESSES"