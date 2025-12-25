# Configure Static IP (Debian tabanlilar icin)
`ip link` komutuyla interface  ismini bul (enp1s0, enp3s0 v.b.) 
Sonra sonra /etc/network klasörü icindeki *.yaml dosyasi icinde asagidakileri yaz. Aq  indentation isine dikkat et
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses:
        - 192.168.122.11/24
      routes:
        - to: default
          via: 192.168.122.1
      
      nameservers:
        addresses: 
          - 127.0.0.53
          - 8.8.8.8

```
sonra `sudo netplan apply` ile uygula. 

## DHCP server kurulumu
sudo apt install kea-dhcp4-server -y
sudo systemctl status  kea-dhcp4-server
mv /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf.bak # yedekledik

/etc/kea/kea-dhcp4.conf # Simdi virgin dosyanin icine yazacaz. Gerektiginde eskiye rahat fönmek icin. Dönenin amq

Örnek kea DHCP4  config file asagida:
```json
#
{
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": [ "eth0" ],
            "dhcp-socket-type": "raw"
        },
        "valid-lifetime": 3600,
        "renew-timer": 900,
        "rebind-timer": 1800,
        "lease-database":
                {
                "type": "memfile",
                "lfc-interval": 3600,
                "name": "/var/lib/kea/kea-leases4.csv"
                },

        "subnet4": [
                {
                "id": 1,
                "subnet": "192.168.122.0/24",
                "pools": [ { "pool": "192.168.122.20-192.168.122.40" } ],
                "option-data": [
                        {
                        "name": "routers",
                        "data": "192.168.122.1"},

                        {
                        "name": "domain-name-servers",
                        "data": "192.168.122.1"},

                        {
                        "name": "domain-search",
                        "data": "example.com"
                        }
                        ],
                "reservations": [
                        {
                        "hw-address": "0e:4a:7a:01:2f:77",
                        "ip-address": "192.168.122.2",
                        "hostname": "kea"
                        }
                        ]
                }
                ]

        }

}
#
```
vim editor icinde :set syntax=json ile mali kontrol et. sonra servisi yeniden baslat;
systemctl restart   kea-dhcp4-server # status ile kontrol et

simdi KVM de dhcp  yi devra disi birakacaz. 
virsh net-edit <network:name> # genelde default. 

Önce edit yapilacak dosyayi 
"/etc/libvirt/qemu/networks/autostart/default.xml"
veya "/etc/libvirt/qemu/networks/default.xml" yedekle sonra dhcp ile ilgili 3 satiri sil . virsh net-destroy default sonra net-start default. 

offer yapan Dhcp server 'sudo nmap --script broadcast-dhcp-discover' ile bulursun. 

Yine DHCP server icinde 'cat /var/lib/kea/kea-leases4.csv ' ile kime hangi ip verildi görürsün

/etc/kea/dhcp4.conf dosyasinda yaptigin degisiklikleri kea-dhcp4 -t  ***.conf ile kontrol edebilirsin 

## Docker ile DHCP4:
docker network create --subnet=192.168.122.0/24 --gateway=192.168.122.1 networkkea

docker network inspect  network

docker run -it --name <name> --privileged --network networkkea  ubuntu bash

calismiyo hic ugrasma amk