What is the loopback device? localhost
NIC bonding: Combining multiple NICs together

Debian UBUNTU
ip a
ip r # sadece routing kismini gösterir daha sadedir
ifup ens3 ifdown ens3
/etc/resokv.conf # old school
systemd : a group of tools  working together
## UBUNTU
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

## RHEL 
NetworkManager
sudo lshw -class network # deeper information
man nmcli-examples 
cockpit kur  sonra
firewall-cmd --add-service=cockpit --permanent
firewall-cmd --reload
web arayüzü  hazir
sudo systemctl status NetworkManager . gives the last 10 logs
sudo journalctl -u NetworkManager | less# entire logs

özellikle ssh baglantilarinda  less mutlak kullanilir. degilse malim tamami görülmez

## COMMANDS

ip l         # data link layer  info

What is MTU?  MTU stands for Maximum Transmission Unit, indicating the largest packet size (in bytes) that a network interface can send without needing to break it into smaller pieces (fragmentation). A common default MTU is 1500 bytes

```bash
ip -br  -4 a bu bi harika. ipv4 leri brief ediyor
ip -o -4 a | column -t
ip r routes
ip -c r | column -t  # c  renklendirir
```
traceroute
```bash
dig example.com
dig  -x IP_Address  # reverse lookup
dig @4.2.2.2 google.com # google.com alan adının IP adresini, 4.2.2.2 DNS sunucusunu kullanarak sorgular.
```

```bash
nmap -sn network_adres.0/24
nmap ip_adress # dzrek hedef detaylarini verir
```
debclient.example.local  ä homelabs icin . local iyi. bu adrese FullyQualifiedDomainName

## Working with  HOSTS file

vim /etc/hosts
172.17.17.20 ans-ubuntu # bunu yazinca artik ans-ubuntu icin dns  geregi yok
mesela

```bash
ssh ansible@ans-ubuntu
```

hosts  dosyasina asagidaki bicimdede yazabilirsin.
172.17.17.20 ans-ubuntu.example.local ans-ubuntu
siralama;  " IP FQDN Hostname " seklinde olur.



`/etc/nsswitch.conf`, isim çözümleme ve kimlik doğrulama işlemlerinde hangi kaynağın hangi sırayla kullanılacağını belirleyen yapılandırma dosyasıdır.
örnegin passwd: files ldap  Kimlik bilgileri önce yerel dosyalardan, sonra LDAP’tan alınır.


/etc/nsswitch.conf sistemi, kullanıcı, grup, hostname ve benzeri sorguların hangi kaynaktan ve hangi sırayla yapılacağını belirler. Örneğin:
passwd satırı → Kullanıcı bilgileri aranacak kaynakların sırası.
group satırı → Grup bilgileri aranacak kaynakların sırası.
hosts satırı → Hostname/IP çözümleme sırası.

/etc/nsswitch.conf dosyasındaki örnek içerik:
passwd:     files sss
group:      files sss
hosts:      files dns
Anlamı:
passwd: files sss → Önce /etc/passwd, sonra SSSD (örn. LDAP) kullanılacak.
hosts: files dns → IP/hostname çözümlemesinde önce /etc/hosts, sonra DNS kullanılacak.

## ss

| Durum               | Ne Anlama Gelir?             |
| ------------------- | ---------------------------- |
| LISTEN              | Port dinlemede. |
| ESTABLISHED         | Aktif bir bağlantı var |
| CLOSE\_WAIT         | Karşı taraf kapattı ama sizin taraf hala kapatmadı |
| TIME\_WAIT          | Bağlantı kapatıldı ama bir süre daha beklemede |
| SYN\_SENT SYN\_RECV | TCP bağlantısı kurulmaya çalışılıyor.  |



ss  -tuln  / ss tulnw



ss -punt
ps  -ef  | grep -i  ssh
ssh  -V versionu verir
scp sourcefile_path  user@IP:/example_path

pgrep  -c ssh   ssh ile kac baglanti var? dikkat burda tek baglanti gidis-gelis 2  sayilir
pgrep -a ssh

## SFTP 
SFTP vs RSYNC Use rsync for performance and automation; use SFTP for interactive management and compatibility.
ANLIK ETKILESIMLI CALISACAKSAN  SFTP KULLAN. SSH tabanli . ekstra bisey kurmana gerek yok
```bash
sftp> ansible@172.17.17.20
sftp> get testfile # dosya indirir
sftp> put /dosya/yolu # file upload
sftp> mkdir etwas_dosyasi # dosxa olusturur
sftp> lls  # lokalde malin incegi  klasörde olanlari siralar
```
## APACHE 
/var/www/html/index.html


## CASE STUDY 
ip_A 192.168.1.A
ip_C 192.168.2.C 
ip_B 192.168.1.B 192.168.2.B 
A 192.168.1.B  aginda C 192.168.2.B aginda ve B her iki agdan ipye sahip. A ile C nasil konusacak. 
 - A dan C ye ulasmak icin A nin terminalde
```bash
ip route add 192.168.2.B.0/24 via 192.168.1.B
```
 - C den A ya ulasmak icin C nin terminale
 ```bash
 ip route add 192.168.1.B/24 via 192.168.2.B
 ```


## Firewall Configuration with `firewalld`
fedore ve RHEL de firewall dan port acma 
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload