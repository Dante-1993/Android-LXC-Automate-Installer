pkg install -y \
  root-repo \
  x11-repo \
  tsu \
  wget \
  curl \
  proot \
  pulseaudio \
  termux-x11-nightly 
su -c "mkdir -p /data/local/lxc
      cd /data/local/lxc
      /data/data/com.termux/files/usr/bin/wget https://github.com/termux-containers/lxc-android/releases/download/v5.0.3/lxc-android-aarch64.tar.xz
      tar -xJf lxc-android-aarch64.tar.xz "
su -c "mkdir -p /data/local/lxc/debian/rootfs \
      cd /data/local/lxc/debian/rootfs
      busybox wget https://github.com/Dante-1993/TermuxChroot-Autoinstall/releases/download/RootFS/debian-arm64.tar.gz 
      tar xpvf debian-arm64.tar.gz -C /data/local/lxc/debian/rootfs"
sudo cp config /data/local/lxc/debian
chmod +x start.sh
cp -v start.sh ~/.shortcuts
