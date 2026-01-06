#!/bin/bash

# --- Ayarlar ---
NEW_VM="ansible-controller"
BASE_IMAGE="/var/lib/libvirt/images/ubuntu_test.qcow2" 
NEW_DISK="/var/lib/libvirt/images/${NEW_VM}.qcow2"
STATIC_IP="10.0.10.11/24"
GW="192.168.122.1"
USER="ansible-cntrl"
PASS="asd"


cp "$BASE_IMAGE" "$NEW_DISK"

# clean with virt-sysprep (logs, hostnames)
virt-sysprep -a "$NEW_DISK" --hostname "$NEW_VM" --operations defaults,ssh-hostkeys


virt-customize -a "$NEW_DISK" \
  --run-command "rm /etc/netplan/*.yaml" \
  --write "/etc/netplan/01-netcfg.yaml:network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: [$STATIC_IP]
      gateway4: $GW
      nameservers:
        addresses: [8.8.8.8]" \
  --password "$USER:password:$PASS" \
  --ssh-inject "$USER:file:$HOME/.ssh/id_rsa.pub" \
  --selinux-relabel

# 4. virt-install ile makineyi kur
virt-install \
  --name "$NEW_VM" \
  --ram 2048 \
  --vcpus 2 \
  --disk path="$NEW_DISK",format=qcow2 \
  --import \
  --os-variant ubuntu22.04 \
  --network bridge=virbr0 \
  --graphics none \
  --noautoconsole