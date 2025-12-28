#!/bin/bash

echo "Yeni ubuntu sanal makine ismi"
read user

SOURCE="/var/lib/libvirt/images/ubuntu24.04.qcow2"
DEST="/var/lib/libvirt/images/$user.qcow2"

sudo cp -p "$SOURCE" "$DEST"

# temizlik ve root sifre 
sudo virt-sysprep -a $DEST --hostname $user.example.com --root-password password:asd --enable customize,dhcp-client-state,net-hostname,net-hwaddr,machine-id


# sudo virt-customize -a $DEST  --ssh-inject ubuntu:file:/root/.ssh/id_rsa.pub

sudo virt-install --name $user --ram 2048 --vcpus 2 --disk path=$DEST --import --os-variant ubuntu24.04 --network default --graphics vnc --noautoconsole
