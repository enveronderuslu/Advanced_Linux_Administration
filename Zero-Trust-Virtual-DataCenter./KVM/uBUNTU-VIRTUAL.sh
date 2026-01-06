#!/bin/bash

echo "Yeni ubuntu sanal makine ismi"
read user

SOURCE="/var/lib/libvirt/images/ansible-controller.qcow2"
DEST="/var/lib/libvirt/images/$user.qcow2"

sudo cp -p "$SOURCE" "$DEST"

sudo virt-sysprep -a "$DEST" \
  --hostname "$user.example.com" \
  --root-password password:asd \
  --operations bash-history,dhcp-client-state,logfiles,machine-id,net-hostname,net-hwaddr,ssh-hostkeys,udev-persistent-net,tmp-files

# NETPLAN ve eski network ayarlarini temizle
sudo virt-customize -a "$DEST" \
  --run-command 'rm -f /etc/netplan/*.yaml' \
  --run-command 'rm -f /etc/cloud/cloud.cfg.d/*net* || true'

sudo virt-install \
  --name "$user" \
  --ram 2048 \
  --vcpus 2 \
  --disk path="$DEST",format=qcow2 \
  --import \
  --osinfo ubuntu22.04 \
  --network network=outof-fw \
  --noautoconsole
