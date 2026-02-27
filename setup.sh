pkg install -y \
  root-repo \
  x11-repo \
  tsu \
  wget \
  curl \
  proot \
  pulseaudio \
  termux-x11-nightly \
  lxc
su -c "mkdir -p /data/local/lxc/debian/rootfs \
      cd /data/local/lxc/debian/rootfs
      busybox wget https://github.com/Dante-1993/TermuxChroot-Autoinstall/releases/download/RootFS/debian-arm64.tar.gz 
      tar xpvf debian-arm64.tar.gz -C /data/local/lxc/debian/rootfs"
sudo cp config /data/local/lxc/debian
sudo lxc-create -n debian -t local \
  -- --rootfs-dir=/data/local/lxc/debian/rootfs
chmod +x start.sh
cp -v start.sh ~/.shortcuts
