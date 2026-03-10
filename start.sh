# Очищаємо старі маунти, якщо вони є
sudo umount -l /sys/fs/cgroup

#Додаємо cgroup v1
udo mount -t tmpfs -o mode=0755 cgroup /sys/fs/cgroup
#sudo mkdir /sys/fs/cgroup/cpu /sys/fs/cgroup/memory /sys/fs/cgroup/devices
#sudo mount -t cgroup -o cpu cgroup /sys/fs/cgroup/cpu
#sudo mount -t cgroup -o memory cgroup /sys/fs/cgroup/memory
#sudo mount -t cgroup -o devices cgroup /sys/fs/cgroup/devices

# Створюємо ієрархію (LXC це любить)
sudo mkdir /sys/fs/cgroup/unified
sudo mount -t cgroup2 none /sys/fs/cgroup/unified

# Якщо твоє ядро підтримує v1 (cpu, mem), можна додати і їх, 
# але для початку вистачить і unified.

sudo lxc-start -n debian -f /data/local/lxc/debian/config -F
