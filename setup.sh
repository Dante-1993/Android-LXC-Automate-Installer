#!/bin/bash

# Шляхи та налаштування
LXC_PATH="/data/local/lxc/debian"
ROOTFS="$LXC_PATH/rootfs"
ARCH="arm64"

echo "[*] Starting automated LXC setup..."

# 1. Встановлення пакунків у Termux (якщо ще немає)
pkg update && pkg install -y root-repo x11-repo tsu wget curl proot pulseaudio termux-x11-nightly lxc busybox

# 2. Створення структури папок
sudo mkdir -p $ROOTFS

# 3. Завантаження та розпакування (якщо порожньо)
if [ ! -f "$ROOTFS/bin/bash" ]; then
    echo "[*] Downloading and extracting Debian rootfs..."
    cd $LXC_PATH
    sudo wget https://github.com/Dante-1993/TermuxChroot-Autoinstall/releases/download/RootFS/debian-arm64.tar.gz
    sudo tar xpvf debian-arm64.tar.gz -C $ROOTFS
    sudo rm debian-arm64.tar.gz
else
    echo "[!] Rootfs already exists, skipping download."
fi

# 4. ФУНКЦІЯ НАЛАШТУВАННЯ ПАРОЛЯ
set_root_password() {
    local PASS="root" # Можна змінити на свій за замовчуванням
    echo "[*] Setting up root password..."
    
    # Використовуємо chroot для виконання команди всередині rootfs
    # chpasswd зручніший для скриптів, ніж passwd
    sudo chroot $ROOTFS /bin/bash -c "echo 'root:$PASS' | chpasswd"
    
    if [ $? -eq 0 ]; then
        echo "[+] Password for 'root' set to: $PASS"
    else
        echo "[!] Failed to set password."
    fi
}

set_root_password

setup_wayland_stack() {
    echo "[*] Installing Wayland, Sway and Mesa drivers inside rootfs..."
    
    # 1. Тимчасово прокидаємо DNS, щоб apt працював всередині chroot
    sudo cp /etc/resolv.conf $ROOTFS/etc/resolv.conf

    # 2. Запускаємо встановлення пакетів
    sudo chroot $ROOTFS /bin/bash -c "
        apt update
        apt install -y \
            sway \
            xwayland \
            mesa-utils \
            libgl1-mesa-dri \
            mesa-vulkan-drivers \
            dbus-x11 \
            weston \
            fonts-dejavu \
            alacritty
        
        # Створюємо папку для рантайму Wayland
        mkdir -p /run/user/0
        chmod 700 /run/user/0
    "
    
    if [ $? -eq 0 ]; then
        echo "[+] Wayland stack installed successfully!"
    else
        echo "[!] Failed to install some packages."
    fi
}

setup_wayland_stack

# 5. Створення/Копіювання конфігу
# Тут ми створюємо базовий конфіг, якщо його немає
if [ ! -f "$LXC_PATH/config" ]; then
    echo "[*] Creating default LXC config..."
    sudo bash -c "cat <<EOF > $LXC_PATH/config
lxc.uts.name = debian
lxc.arch = linux64
lxc.rootfs.path = dir:$ROOTFS
lxc.net.0.type = none
lxc.mount.auto = proc:rw sys:rw cgroup:rw
lxc.cap.drop =
lxc.apparmor.profile = unconfined
lxc.seccomp.profile = 
lxc.cgroup.devices.allow = a
lxc.cgroup.relative = 0
lxc.cgroup.dir = lxc_container
lxc.autodev = 1
lxc.cgroup.pattern = /lxc/%n
lxc.mount.entry = /dev/dri dev/dri none bind,optional,create=dir 0 0
lxc.mount.entry = /dev/kgsl-3d0 dev/kgsl-3d0 none bind,optional,create=file 0 0
lxc.mount.entry = /data/data/com.termux/files/usr/tmp/.X11-unix tmp/.X11-unix none bind,optional,create=dir 0 0
EOF"
fi

# 6. Реєстрація в LXC
echo "[*] Registering container in LXC..."
sudo lxc-create -n debian -t local -- --rootfs=$ROOTFS

echo "[+] Setup complete! Use ./start.sh to launch."
