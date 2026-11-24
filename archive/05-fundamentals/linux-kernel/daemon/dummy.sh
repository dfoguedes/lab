#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root to write to /var/log/dummy-service.log" >&2
  exit 1
fi

while true; do
  echo "Dummy service is running..." >> /var/log/dummy-service.log
  sleep 10
done

