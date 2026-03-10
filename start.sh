#!/bin/bash

# Шляхи
CONF_PATH="/data/local/lxc/debian/config"
NAME="debian"

echo "[*] Preparing environment..."

# Очищення та підготовка cgroups
# 1. Примусово відмонтовуємо все, що стосується cgroup
sudo umount -l /sys/fs/cgroup/unified 2>/dev/null
sudo umount -l /sys/fs/cgroup 2>/dev/null

# 2. Створюємо чистий tmpfs для ієрархії
sudo mount -t tmpfs -o mode=0755 cgroup /sys/fs/cgroup

# 3. Монтуємо cgroup v2 безпосередньо в корінь (без папки unified)
sudo mount -t cgroup2 none /sys/fs/cgroup

# 4. ВАЖЛИВО: дозволяємо делегування
su -c 'echo "+cpuset +cpu +io +memory +pids" > /sys/fs/cgroup/cgroup.subtree_control'


# Спроба підняти cgroup v1 контролери (якщо ядро підтримує)
#for controller in cpu memory devices; do
#    sudo mkdir -p /sys/fs/cgroup/$controller
#    sudo mount -t cgroup -o $controller cgroup /sys/fs/cgroup/$controller 2>/dev/null
#done

# Виправлення прав для терміналу
sudo chmod 666 /dev/pts/ptmx 2>/dev/null

echo "[*] Starting LXC container..."
sudo lxc-start -n $NAME -f $CONF_PATH -F
