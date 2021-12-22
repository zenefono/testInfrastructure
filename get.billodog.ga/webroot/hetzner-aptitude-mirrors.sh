#!/usr/bin/env bash

echo "WARNING: this will override your /etc/apt/sources.list file and remove any customization"
read -p "Do you still want to continue? [y/N]: " CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
  cat > /etc/apt/sources.list <<EOF
deb http://mirror.hetzner.de/debian/packages   buster         main contrib non-free
deb http://mirror.hetzner.de/debian/security   buster/updates main contrib non-free
deb http://mirror.hetzner.de/debian/packages   buster-updates main contrib non-free

deb http://deb.debian.org/debian/              buster         main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb http://deb.debian.org/debian/              buster-updates main contrib non-free
EOF
fi
