#!/bin/bash
echo "Yeni ubuntu sanal makine ismi"
read user

SOURCE="/var/lib/libvirt/images/SEC-IPS.qcow2"
DEST="/var/lib/libvirt/images/$user.qcow2"

sudo cp -p "$SOURCE" "$DEST"

# temizlik ve root sifre 
sudo virt-sysprep -a $DEST --hostname $user.example.local --root-password password:asd --enable customize,dhcp-client-state,net-hostname,net-hwaddr,machine-id

sudo virt-install --name $user --ram 1024 --vcpus 1 --disk path=$DEST --import --os-variant fedora41 --network network=lan --graphics vnc --noautoconsole
