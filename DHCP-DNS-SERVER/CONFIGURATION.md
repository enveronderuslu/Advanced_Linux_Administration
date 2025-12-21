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

```
sonra `sudo netplan apply` ile uygula. 


