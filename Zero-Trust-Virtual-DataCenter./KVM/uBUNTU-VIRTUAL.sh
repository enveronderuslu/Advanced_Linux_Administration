#!/bin/bash

echo "Yeni Ubuntu sanal makine ismi:"
read VM_NAME

echo "Yeni kullanıcı adı:"
read VM_USER

echo "Statik IP adresi (ör: 192.168.122.100/24):"
read VM_IP


SOURCE="/var/lib/libvirt/images/ubuntu-original.qcow2"
DEST="/var/lib/libvirt/images/$VM_NAME.qcow2"

sudo cp -p "$SOURCE" "$DEST"

# Temizlik, hostname ve root şifre
sudo virt-sysprep -a $DEST \
  --hostname $VM_NAME.example.com \
  --root-password password:asd \
  --enable customize,dhcp-client-state,net-hostname,net-hwaddr,machine-id

# Kullanıcı oluşturma ve SSH anahtar ekleme
sudo virt-customize -a $DEST \
  --run-command "useradd -m -s /bin/bash $VM_USER" \
  --ssh-inject $VM_USER:file:/root/.ssh/id_rsa.pub \
  --run-command "echo '$VM_USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"


# VM kurulum
virt-install \
  --name ubuntu_vm \
  --memory 2048 \
  --location archive.ubuntu.com \
  --network network=default \
  --extra-args "netcfg/get_nameservers=10.0.2.5 netcfg/get_ipaddress=10.0.2.4 netcfg/get_netmask=255.255.255.0  netcfg/get_gateway=10.0.2.1 netcfg/confirm_static=true"
