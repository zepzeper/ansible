#!/usr/bin/env bash
set -euo pipefail

# Build a Debian netinstall USB with preseed injected
# Usage: ./build-usb.sh [device]   (e.g. ./build-usb.sh /dev/sdb)
# If no device given, just builds the ISO in /tmp

: "${DEBIAN_VERSION:=13.5.0}"
: "${DEBIAN_ISO:=debian-${DEBIAN_VERSION}-amd64-netinst.iso}"
: "${DEBIAN_URL:=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/${DEBIAN_ISO}}"
: "${PRESEED:=ds10u-preseed.cfg}"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "==> Downloading Debian ${DEBIAN_VERSION} netinstall..."
wget -c "$DEBIAN_URL" -O "$TMPDIR/$DEBIAN_ISO"

echo "==> Extracting ISO..."
xorriso -osirrox on -indev "$TMPDIR/$DEBIAN_ISO" -extract / "$TMPDIR/iso/"

echo "==> Injecting preseed..."
cp "$(dirname "$0")/$PRESEED" "$TMPDIR/iso/preseed.cfg"

echo "==> Configuring boot to auto-load preseed..."
cat > "$TMPDIR/iso/isolinux/txt.cfg" << 'ISOCFG'
default auto
label auto
  menu label ^Automated install (preseed)
  kernel /install.amd/vmlinuz
  append vga=788 initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed.cfg auto=true priority=critical --- quiet
ISOCFG

cat > "$TMPDIR/iso/boot/grub/grub.cfg" << 'GRUBCFG'
insmod part_gpt
insmod ext2
set timeout=1
menuentry "Automated install (preseed)" {
  set gfxpayload=keep
  linux /install.amd/vmlinuz preseed/file=/cdrom/preseed.cfg auto=true priority=critical quiet ---
  initrd /install.amd/initrd.gz
}
GRUBCFG

echo "==> Rebuilding ISO..."
MBR=""
for p in /usr/lib/ISOLINUX/isohdpfx.bin /usr/lib/syslinux/isohdpfx.bin /usr/share/syslinux/isohdpfx.bin; do
  [ -f "$p" ] && MBR="$p" && break
done

xorriso -as mkisofs -r -V "Debian Auto" \
  -J -joliet-long -cache-inodes \
  ${MBR:+-isohybrid-mbr "$MBR"} \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -boot-load-size 4 -boot-info-table -no-emul-boot \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat \
  -o "$TMPDIR/debian-preseed.iso" \
  "$TMPDIR/iso/"

echo "==> Done: $TMPDIR/debian-preseed.iso"

if [ -n "${1:-}" ]; then
  DEVICE="$1"
  echo "==> Writing to $DEVICE..."
  sudo dd if="$TMPDIR/debian-preseed.iso" of="$DEVICE" bs=4M status=progress conv=fsync
  echo "==> USB ready! Boot $DEVICE on ds10u."
else
  echo "==> ISO ready. No device specified."
  echo "    Write it: sudo dd if=$TMPDIR/debian-preseed.iso of=/dev/sdX bs=4M status=progress conv=fsync"
fi
