#!/bin/bash

lvmimgsize="10G"
lvmpoolsize="9G"
lvmpool="/lvm-pool"
lvmimg="$lvmpool/lxd-thin.img"
vgname="lxd-vg"
thinpoolname="lvm-cont"

set -euo pipefail

sudo pacman -Syu --noconfirm

echo "[*] For now use this only after you installed lxd!"

# pkg="lxd"
# 
# echo "[*] Checking for conflicts..."
# 
# if ! sudo pacman -S --noconfirm --needed --print-format "%n" "$pkg" >/dev/null 2>&1; then
#     echo "[!] Conflicts detected. Trying safe removal of conflicting packages..."
#     # Identify the conflicting packages
#     conflicts=$(sudo pacman -S --print-format "%n" "$pkg" 2>&1 | grep "conflicts with" | awk '{print $NF}')
#     if [[ -n "$conflicts" ]]; then
#         echo "[*] Removing conflicts: $conflicts"
#         sudo pacman -Rns --noconfirm $conflicts
#     fi
# fi
# 
# echo "[*] Installing $pkg..."
# 
# sudo pacman -S --noconfirm --needed "$pkg" lvm2

sudo systemctl enable --now lxd

# init lxd - it will not create storage yet
sudo lxd init --pressed < preseed.yaml

# installing lvm and configuring it for lxd
sudo pacman -S --noconfirm --needed lvm2
sudo mkdir -p $lvmpool
sudo truncate -s $lvmimgsize $lvmimg

sudo losetup -fP $lvmimg

loop_device=$(sudo losetup -a | awk '{print $1}' | cut -d ':' -f 1 )
echo "[*] Loop device created: $loop_device"

# Create physical volume
sudo pvcreate "$loop_device"

# Create volume group
sudo vgcreate "$vgname" "$loop_device"

# Create thin pool
sudo lvcreate --type thin-pool -n "$thinpoolname" "$vgname" -L "$lvmpoolsize"

echo "[*] LVM thin pool setup complete:"
sudo lvs

# create lxd storage inside the lvm
echo "[*] LXD Storage creation..."
sudo lxc storage create mylvm lvm source="$vgname" lvm.thinpool_name="$thinpoolname"

echo "[*] LXD Storage created:"
sudo lxc storage list

echo "[*] LXD X11 forwarding profile creation..."
sudo lxc profile create x11-profile
sudo lxc profile device add x11-profile X0 proxy connect=unix:/tmp/.X11-unix/X0 listen=unix:/tmp/.X11-unix/X0 bind=container
sudo lxc profile set x11-profile environment.DISPLAY :0
sudo lxc profile set x11-profile environment.XAUTHORITY /root/.Xauthority

echo "[*] LXD X11 fowarding profile created:"
sudo lxc profile show x11-profile



