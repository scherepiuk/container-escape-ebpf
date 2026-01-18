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

# Install tetragon
curl -LO https://github.com/cilium/tetragon/releases/download/v1.6.0/tetragon-v1.6.0-amd64.tar.gz
tar -xvf tetragon-v1.6.0-amd64.tar.gz
tetragon-v1.6.0-amd64/install.sh
rm -rf tetragon-v1.6.0-amd64.tar.gz tetragon-v1.6.0-amd64

# Copy PoCs to a non-tmpfs filesystem
mkdir /pocs && cp /tmp/pocs/* /pocs

# Copy utility scripts to a non-tmpfs filesystem
mkdir /utils && cp /tmp/utils/* /utils
chmod a+x /utils/reset.sh

# Copy the rules and stop tetragon service initially
cp /tmp/rules/* /etc/tetragon/tetragon.tp.d
systemctl stop tetragon

# Set setuid bit on runc
chmod u+s /usr/local/bin/runc
