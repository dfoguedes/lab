#! /bin/bash
set -euo pipefail # Fail on error, unset variable, and pipefail
# This script installs Apache2 on a Debian-based system.
apt-get update
sudo apt install -y apache2