#!/bin/bash
set -e

RUNC_VERSION="${runc_version}"

# Update system
apt-get update
apt-get install -y wget

# Install runc
wget -q https://github.com/opencontainers/runc/releases/download/v$RUNC_VERSION/runc.amd64
install -m 755 runc.amd64 /usr/local/bin/runc
rm runc.amd64

# Set setuid bit on runc
chmod u+s /usr/local/bin/runc
