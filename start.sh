sudo mount -t tmpfs -o mode=0755 cgroup /sys/fs/cgroup
sudo mkdir /sys/fs/cgroup/cpu /sys/fs/cgroup/memory /sys/fs/cgroup/devices
sudo mount -t cgroup -o cpu cgroup /sys/fs/cgroup/cpu
sudo mount -t cgroup -o memory cgroup /sys/fs/cgroup/memory
sudo mount -t cgroup -o devices cgroup /sys/fs/cgroup/devices
sudo lxc-start -n debian -f /data/local/lxc/debian/config -F
