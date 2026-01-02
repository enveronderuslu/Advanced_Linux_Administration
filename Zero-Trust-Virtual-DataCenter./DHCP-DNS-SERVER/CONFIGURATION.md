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
        - 10.0.2.6/24
      routes:
        - to: default
          via: 10.0.2.1
      
      nameservers:
        addresses: 
          - 127.0.0.53
          - 10.0.2.5
        search:
          - example.com 

```

sonra `sudo netplan apply` ile uygula. 

RHEL tabanli sistemlerde /etc/NetworkManager/system-connections icinde yapilir.

```vim
[ipv4]
address1=10.0.2.6/24
dns=10.0.2.5;
dns-search=example.com;
gateway=10.0.2.1
method=manual
```

veya komutla 

```bash
sudo nmcli con mod enp1s0 ipv4.addresses 10.0.2.6/24
sudo nmcli con mod enp1s0 ipv4.gateway 10.0.2.1
sudo nmcli con mod enp1s0 ipv4.method manual
sudo nmcli con mod enp1s0 ipv4.dns "10.0.2.5"
sudo nmcli con mod enp1s0 ipv4.dns-search "example.com"
sudo nmcli con up enp1s0
nmcli device show enp1s0
```

systemctl restart NetworkManager yapmayi unutma

# DHCP server kurulumu
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
            "interfaces": [ "enp1s0" ],
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
                "subnet": "10.0.2.0/24",
                "pools": [ { "pool": "10.0.2.110-10.0.2.130" } ],
                "option-data": [
                        {
                        "name": "routers",
                        "data": "10.0.2.1"},

                        {
                        "name": "domain-name-servers",
                        "data": "10.0.2.1"},

                        {
                        "name": "domain-search",
                        "data": "example.com"
                        }
                        ],
                "reservations": [
                        {
                        "hw-address": "52:54:00:26:1c:97",
                        "ip-address": "10.0.2.4",
                        "hostname": "dhcp1.example.com"
                        },
                        {
                        "hw-address": "52:54:00:c4:63:97",
                        "ip-address": "10.0.2.5",
                        "hostname": "dns1.example.com"
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

# DNS server 
bilgi: test.example.com Burada test-->hostname example.com-->domain name
resolvectl status # mevcut kullanikan DNS server adresini verir

serverlarda hostname  leri düzenle. Örnegin dns1  serverda ` hostnamextl set-hostname dns1.example.com` yap. Tüm serverlarda asagidakinin benzeri ayarlama yap. 
Bu server icinde
`vim /etc/hosts -> 10.0.2.5 dnas1.example.com dns1`


server kurulumu icin `apt update && apt install bind9 bind9-utils bind9-dnsutils -y` calistir

yine dhcp server icinde /etc/kea/kea-dhcp4.conf dosyasi icinde dns server ip adresini (10.0.2.5) yaz (ayarlamalar yapilana kadar bu server internete cikamaz)

dns1 server icinde 

```bash
vim /etc/default/named
OPTIONS="-u bind -4"  # satirini düzenle. sadece IPv4 kullan dedik
```

Simdi  /etc/bind/named.conf.options dosyasini  düzenle. önce yedekle (cp file file.bak). Sonra asagidaki parcayi ekle

```vim
        listen-on  {127.0.0.1; 10.0.2.5; };
        allow-query { localhost; 10.0.2.0/24; };
        allow-transfer { none; };

        forwarders { 10.0.2.1; };
        recursion yes;
```

simdi /etc/bind/named.conf.local modifiye edilecek.  

```vim
zone "example.com" 
	{
	type master;
	file "/etc/bind/zones/db.example.com"; 
	};

zone "2.0.10.in-addr.arpa"
	{
	type master;
	file "/etc/bind/zones/db.2.0.10";
	};
```

birinci kisim 'forward lookup' isimden ip ye 
ikinci kisim 'reverse lookup' ip den isme. benim network 10.0.2.0/24 oldugundan  network adresi 10.0.2. Reverse yazilacagindan buraya 2-0-10 yazildi 
Simdi /etc/bindicinde /zones klasörünü olustur. icine db.example.com ve db.2.0.10 dosyalarini ekle. dosyalar üst kalsörde
Asagidaki komutlarla konfigurasyonu dogrulat
named-checkzone 
named-checkzone example.com /etc/bind/zones/db.example.com
named-checkzone 2.0.10.in-addr.arpa /etc/bind/zones/db.2.0.10
reboot yap. cicek...

resolvectl ile serverin dns ayarlarina bakarsin. 

# DIRECTORY SERVICES-SERVER

sudo dnf update -y && sudo reboot
sudo dnf install freeipa-server freeipa-server-dns -y
sudo ipa-server-install

fedora server kur. static ip ve dns konfig yap sobra;


/tmp icinde ki ipa.system.records.hmei6av6.db dosyasinin icerigini kopyala ve dns server da bind/zones icinde  db.example.com  dosyasiin götüne kopyala. 
Sonra id1 serverda firewall kurallariyla port lari ac; 

```bash
firewall-cmd --list-ports 
firewall-cmd --add-port={123,88,464}/udp --permanent
firewall-cmd --add-port={80,442,689,636,88,464}/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-ports # kontrol icin 
```


freeipa kurduktan sonra ca-agent.p12, cacert.p12(en önemlisi bu) ve .dogtag gibi dosyalar olusur. Bunlari `ipa-backup` ile yedeklemek lazim. 

LDAP dizin verileri (kullanıcılar, gruplar, politikalar), CA (Sertifika Otoritesi) dosyaları, DNS kayıtları ve Kerberos anahtarları yedeklenir ve varsayılan olarak /var/lib/ipa/backup/ dizini saklanır.

## Create Users 
```bash
kinit admin  # admin olarak sisteme girdin. Obtain Kerberis ticket
ipa user-add (name:test last name:user)
ipa user-del test-user
ipa user-add cemsit-ademov
ipa user-find --login=c.ademov
ipa user-find --last=ademov
ipa user-find --first=CeMsIt # case sensitive degil
ipa user-find --all ( > users.txt) #basta admin olmak üzere tüm users

```

ipa group-find --all
dn: cn=admins,cn=groups,cn=accounts,dc=example,dc=com

Bu bir DN (Distinguished Name) kaydıdır.

dn: (Distinguished Name): Bu nesnenin dizin ağacındaki tam ve benzersiz adresidir. Dosya sistemindeki /home/user/dosya.txt gibi bir yol (path) mantığıyla çalışır ancak **sağdan sola doğru okunur.**

cn=admins (Common Name): 
cn=accounts: Grupların ve kullanıcıların bulunduğu ana hesaplar bölümünü ifade eder.
dc=example,dc=com (Domain Component): Bu, dizinin hangi alan adına (domain) ait olduğunu belirtir. Bu örnekte example.com alan adını temsil eder.

com (En üst seviye domain)
example (Alt domain)
accounts (Hesaplar klasörü)
groups (Gruplar alt klasörü)
admins (Yönetici grubu nesnesi)

ipa group-add # grup olusturuldu

### Permission vs. Privilige  

Permissions (İzinler): Doğrudan bir nesne (dosya, LDAP kaydı, veritabanı tablosu) üzerinde ne yapılabileceğini tanımlar. Bir nesnenin "özelliğidir".
Privileges (Ayrıcalıklar): Bir kullanıcı veya rolün sistem genelinde veya belirli bir görev kapsamında sahip olduğu "yetenekler" bütünüdür. Bir aktörün (kişi veya sistem hesabı) "özelliğidir". 


Permission (Anahtar)	Privilege (Anahtarlik)

## Accounts

. Host Account (Sunucu Hesabı)
Bu hesap, fiziksel veya sanal bir makineyi temsil eder.
Kullanım Amacı: Sunucunun merkezi sisteme güvenli bir şekilde bağlanması, kendi servisleri için sertifika alması ve ağdaki diğer kaynaklara (örneğin bir dosya paylaşımı) makine düzeyinde erişmesi içindir.

Kimlik Doğrulama: Genellikle bir şifre ile değil, (Kerberos) ile otomatik olarak gerçekleşir. Örnek: Bir web sunucusunun (web01.example.com), kullanıcıların şifrelerini doğrulamak için FreeIPA ile konuşabilmesi bu hesap sayesinde olur. 

. User Account (Kullanıcı Hesabı)
Gerçek bir kişiyi (insanı) temsil eder. 
Kullanım Amacı: Bir kişinin bilgisayara giriş yapması, e-postalarına bakması veya yetkisi dahilindeki dosyalara erişmesidir.

. Service Account (Servis Hesabı)
Belirli bir yazılımın veya uygulamanın (insan müdahalesi olmadan) çalışması için oluşturulan hesaplardır. Arka planda çalışan servislerin (örneğin bir veritabanı yedeği alan betik veya bir web uygulaması) sistem kaynaklarına erişmesini sağlar.


## HOSTS
ipa host-find --all # finds the hosts on domain
ipa host-add dhcp1.example.com

## Connecting Client to Directory Server (DS)

client makinede dns ve statik ip ayrlarini yap. Sonra;
```bash
sudo dnf install freeipa-client
sudo ipa-client-install --mkhomedir
reboot
```

Ne iskime yarayacak bunlar ?
. client ta 'kinit admin' yap. Freeipa da olusturulan users sorgula  'id c.ademov' 

. Simdi user lara sudo hakki verilecek. FreeIPA Server Terminalinde:
```bash
ipa sudorule-add rule-name-SUDO1
ipa sudorule-add-user rule-name-SUDO1 --users=c.ademov
ipa sudorule-add-host rule-name-SUDO1 --hosts=fedoraws1.example.com
ipa sudorule-mod rule-name-SUDO1 --cmdcat=all
``` 
gözünaydin. artik fedoraws1  de c.ademov kullanicisiyla calisabilirsin. 

GUI daha iyi dersen ;
. Policy → Sudo → Sudo Rules
. Add ile kural oluştur
. Users sekmesinden kullanıcı ekle
. Hosts sekmesinden host ekle
. Commands sekmesinde Allow all commands seç
. Gerekirse RunAs sekmesinde ALL tanımla

systemctl  --failed # shows  the failed services
