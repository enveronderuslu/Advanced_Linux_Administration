
Debian UBUNTU
ip a
ip r # sadece routing kismini gösterir daha sadedir
ifup ens3 ifdown ens3
/etc/resokv.conf # old school
systemd : a group of tools  working together
UBUNTU
systemctl status  systemd-networkd
netplan icindeki dosyada renderer kisminda networkd yerine NetworkManager yazarsin. systemctl stop and disable systemd-networkd yap NetworkManager kur baslat.
networkctl
networkctl status # bunun ciktisinda eski  loglari görürsün
dns  isi ubuntu da /etc/systemd/resolveD.conf  dosyasindada yapiliyor. Eee aq hangisi?
belirleyici olan netplan  icindeki  dosya

Dosya	Öncelik	Rol	Etki
/etc/netplan/50-cloud-init.yaml	1	DNS tanımı	Aktif
/etc/systemd/resolved.conf	2	Davranış ayarları	Destekleyici
/etc/resolv.conf	3	Otomatik çıktı	Etkisiz

resolvectl
resolvectl status

RHEL NetworkManager
cockpit kur  sonra
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
web arayüzü  hazir
sudo systemctl status NetworkManager . gives the last 10 logs
sudo journalctl -u NetworkManager | less# entire logs

özellikle ssh baglantilarinda  less mutlak kullanilir. degilse malim tamami görülmez

COMMANDS


ip l         # data link layer  info

What is MTU?  MTU stands for Maximum Transmission Unit, indicating the largest packet size (in bytes) that a network interface can send without needing to break it into smaller pieces (fragmentation). A common default MTU is 1500 bytes

ip -4 a  network layer bilgileri getirir
ip  -br a  sadece lazim olani briefly veriyor.
ip -br  -4 a bu bi harika
ip -j -p a   >>  ip.json   ip.json dosyasi olusturdu

ip -o -4 a | column -t

ip r routins
ip -c r | column -t  # c  renklendirir

zraceroute

dig example.com
dig  -x IP_Address  # reverse lookup

nmap -sn ipblogu/24
nmap ip_adresse dzrek hedef detaylarini verir

debclient.example.local  ä homelabs icin . local iyi. bu adrese FullyQualifiedDomainName

Working with  HOSTS file

vim /etc/hosts
172.17.17.20 ans-ubuntu # bunu yazinca artik ans-ubuntu icin dns  geregi yok
mesela
```bash
ssh ansible@ans-ubuntu
``` calisir.
asagidaki bicimdede yazabilirsin.
172.17.17.20 ans-ubuntu.example.local ans-ubuntu
yani IP FQDN hostname seklinde olur.

ss  -tuln  / ss tulnw


pgrep  -c ssh   ssh ile kac baglanti var? dikkat burda tek baglanti gidis-gelis 2  sayilir
pgrep -a ssh
ss -punt
ps  -ef  | grep -i  ssh
ssh  -V versionu verir
scp sourcefile_path  user@IP:/example_path

SFTP vs RSYNC Use rsync for performance and automation; use SFTP for interactive management and compatibility.
ANLIK ETKILESIMLI CALISACAKSAN  SFTP KULLAN. SSH tabanli . ekstra bisey kurmana gerek yok

sftp> ansible@172.17.17.20
sftp> get testfile Disyayi indirir
sftp> put /dosya/yolu
sftp> mkdir etwas_dosyasi
sftp> lls  lokalde malin incegi  klasörde olanlari siralar

APACHE 
/var/www/html/index.html




