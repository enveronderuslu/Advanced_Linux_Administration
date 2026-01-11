#!/bin/bash

echo "Yeni fedora sanal makine ismi"
read user

SOURCE="/var/lib/libvirt/images/ans-fedora.qcow2"
DEST="/var/lib/libvirt/images/$user.qcow2"

sudo cp -p "$SOURCE" "$DEST"

# temizlik ve root sifre 
sudo virt-sysprep -a $DEST --hostname $user.example.com --root-password password:asd --enable customize,dhcp-client-state,net-hostname,net-hwaddr,machine-id


# sudo virt-customize -a $DEST  --ssh-inject fedora:file:/root/.ssh/id_rsa.pub

sudo virt-install --name $user --ram 2048 --vcpus 2 --disk path=$DEST --import --os-variant fedora41 --network network=outof-fw --graphics vnc --noautoconsole

