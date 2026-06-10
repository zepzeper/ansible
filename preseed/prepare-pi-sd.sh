#!/usr/bin/env bash
set -euo pipefail

# Prepare a Raspberry Pi SD card with Debian, headless
# Usage: ./prepare-pi-sd.sh /dev/mmcblk0 [debian-img]

if [ -z "${1:-}" ]; then
  echo "Usage: $0 /dev/mmcblk0 [debian-*-arm64.img]"
  exit 1
fi

DEVICE="$1"
IMAGE="${2:-}"

if [ -z "$IMAGE" ]; then
  IMAGE="debian-12-generic-arm64.img"
  if [ ! -f "$IMAGE" ]; then
    echo "Downloading Debian 12 ARM64..."
    wget -O "$IMAGE.xz" "https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.8.0-arm64-netinst.iso"
    echo "Not a direct SD image — download a prebuilt one from:"
    echo "  https://raspi.debian.net/tested-images/"
    exit 1
  fi
fi

echo "==> Writing $IMAGE to $DEVICE..."
sudo dd if="$IMAGE" of="$DEVICE" bs=4M status=progress conv=fsync

# Find and mount boot partition
BOOT_PART="${DEVICE}p1"
if [ ! -b "$BOOT_PART" ]; then
  BOOT_PART="${DEVICE}1"
fi

echo "==> Mounting boot partition..."
TMPMNT=$(mktemp -d)
sudo mount "$BOOT_PART" "$TMPMNT"

# Enable SSH
echo "==> Enabling SSH..."
sudo touch "$TMPMNT/ssh"

# Create admin user
echo "==> Creating admin user..."
read -s -p "Enter password for admin user: " PASS
echo ""
HASH=$(mkpasswd --method=SHA-512 "$PASS")
echo "admin:$HASH" | sudo tee "$TMPMNT/userconf.txt"

# Optional: configure network
echo "==> Writing network config..."
sudo mkdir -p "$TMPMNT/network"
cat << NETCFG | sudo tee "$TMPMNT/network/interfaces"
auto eth0
iface eth0 inet dhcp
NETCFG

sudo umount "$TMPMNT"
rmdir "$TMPMNT"

echo "==> Done! SD card ready."
echo "    Insert into Pi, connect ethernet + power."
echo "    SSH: ssh admin@pi (once you find its IP)"
