#!/bin/bash

# Шляхи (підправ під свої)
LXC_NAME="debian"
LXC_PATH="/data/data/com.termux/files/usr/var/lib/lxc/$LXC_NAME"
ROOTFS="$LXC_PATH/rootfs"

echo "[*] Creating container $LXC_NAME..."
# Створюємо контейнер (додаємо --no-validate, якщо проблеми з ключами)
sudo lxc-create -n $LXC_NAME -t download -- -d debian -r trixie -a arm64 --no-validate

# ПЕРЕВІРКА 1: Чи розпакувався rootfs?
if [ ! -f "$ROOTFS/bin/bash" ]; then
    echo "[!] Error: Rootfs is empty or tar failed. Check internet/space."
    exit 1
fi

echo "[*] Fixing DNS for container..."
# В Android немає /etc/resolv.conf, створюємо його вручну для apt
sudo mkdir -p "$ROOTFS/etc"
echo "nameserver 8.8.8.8" | sudo tee "$ROOTFS/etc/resolv.conf"

echo "[*] Preparing mount points for chroot..."
# Монтуємо необхідне для роботи apt всередині chroot
sudo mount --bind /dev "$ROOTFS/dev"
sudo mount --bind /dev/pts "$ROOTFS/dev/pts"
sudo mount -t proc proc "$ROOTFS/proc"
sudo mount -t sysfs sys "$ROOTFS/sys"

echo "[*] Installing Wayland, Sway and Mesa..."
# Тепер chroot спрацює, бо є /bin/bash і змонтовані системні папки
sudo chroot "$ROOTFS" /bin/bash <<EOF
apt update
apt install -y --no-install-recommends \
    sway \
    weston \
    mesa-vulkan-drivers \
    libgl1-mesa-dri \
    xwayland \
    dbus \
    alacritty
apt clean
EOF

echo "[*] Unmounting helper partitions..."
sudo umount "$ROOTFS/dev/pts"
sudo umount "$ROOTFS/dev"
sudo umount "$ROOTFS/proc"
sudo umount "$ROOTFS/sys"

echo "[+] Setup complete!"
