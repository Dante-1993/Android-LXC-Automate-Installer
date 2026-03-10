#!/bin/bash

# Шляхи
CONF_PATH="/data/local/lxc/debian/config"
NAME="debian"

echo "[*] Preparing environment..."

# Очищення та підготовка cgroups
sudo umount -l /sys/fs/cgroup 2>/dev/null
sudo mount -t tmpfs -o mode=0755 cgroup /sys/fs/cgroup

# Створюємо ієрархію cgroup v2 (unified)
sudo mkdir -p /sys/fs/cgroup/unified
sudo mount -t cgroup2 none /sys/fs/cgroup/unified

# Спроба підняти cgroup v1 контролери (якщо ядро підтримує)
for controller in cpu memory devices; do
    sudo mkdir -p /sys/fs/cgroup/$controller
    sudo mount -t cgroup -o $controller cgroup /sys/fs/cgroup/$controller 2>/dev/null
done

# Виправлення прав для терміналу
sudo chmod 666 /dev/pts/ptmx 2>/dev/null

echo "[*] Starting LXC container..."
sudo lxc-start -n $NAME -f $CONF_PATH -F
