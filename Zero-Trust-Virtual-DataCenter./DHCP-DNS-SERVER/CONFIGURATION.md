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
        - 192.168.122.200/24
      routes:
        - to: default
          via: 192.168.122.1
      
      nameservers:
        addresses: 
          - 127.0.0.53
          - 192.168.122.1
          - 8.8.8.8
        search:
          - example.local 

```





sonra `sudo netplan apply` ile uygula. 

RHEL tabanli sistemlerde /etc/NetworkManager/system-connections icinde yapilir.

```vim
[connection]
id=enp1s0
type=ethernet
interface-name=enp1s0

[ipv4]
method=manual
addresses=192.168.122.183/24,192.168.122.1
dns=192.168.122.1,8.8.8.8;
dns-search=example.local

[ipv6]
method=ignore

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
resolvectl status # mevcut kullanilan DNS server adresini verir

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


simdi /etc/bind/named.conf.local modifiye edilecek.  




Simdi /etc/bind icinde /zones klasörünü olustur. icine db.example.com ve db.2.0.10 dosyalarini ekle. dosyalar üst kalsörde
Asagidaki komutlarla konfigurasyonu dogrulat
sudo named-checkconf -z
sudo systemctl restart named
reboot yap. cicek...

resolvectl ile serverin dns ayarlarina bakarsin. 
firewall ayarlari;
allow dns  server access to  1.1.1.1

1. Adım: Alias Oluştur (Ağ Grubu)
Firewall > Aliases > IP sekmesine git.

Add butonuna bas.

Name: DNS_Allowed_Networks (veya benzeri bir isim).

Type: Network(s).

Networks: Aşağıdaki tüm ağlarını buraya ekle:

10.0.20.0/24 (CORP)

10.0.40.0/24 (APP)

10.0.50.0/24 (DB)

10.0.60.0/24 (SEC)

Kaydet ve Apply Changes yap.

2. Adım: Tek Bir Firewall Kuralı Yaz
Normalde her arayüzün (interface) kendi sekmesinde kural yazılır. Ancak tüm bu ağlar üzerinde tek bir kural işletmek istiyorsan Floating Rules sekmesini kullanabilirsin:

Firewall > Rules > Floating sekmesine git.

Action: Pass.

Quick: İşaretle (Kuralın hemen işlenmesi için).

Interface: CORP-LAN, APP-LOGIC, DB, SEC (Hepsini seç - Ctrl/Cmd ile).

Direction: in.

Protocol: TCP/UDP.

Source: Single host or alias -> DNS_Allowed_Networks (Az önce oluşturduğun alias).

Destination: Single host or alias -> 10.0.10.5 (DNS Sunucun).

Destination Port Range: 53 (DNS).

# SQUID Proxy Server Configuration

Objective: To implement a lightweight, secure gateway for internal zones (MGMT, APP, DB) to access the internet for updates while maintaining strict "Zero Trust" control with minimal resource consumption.
Installation
The proxy service is hosted on an Ubuntu VM within the SEC Zone (10.0.60.0/24).
sudo apt update && sudo apt install squid -y
Configuration & Access Control
Refer to the Official Ubuntu Documentation for base settings. Custom configurations and segment-specific whitelists are located in Infrastructure/Squid folder.
Backup and Validation

```bash
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
sudo squid -k parse
sudo systemctl restart squid
sudo systemctl enable squid
```

Permissions Management 
```bash
sudo chown -R proxy:proxy /etc/squid/whitelists
sudo chmod -R 644 /etc/squid/whitelists/*.txt
sudo chown -R proxy:proxy /var/log/squid
sudo chown -R proxy:proxy /var/spool/squid
```
Firewall Implementation
Allow internal segments to reach Squid Proxy
Alias Definition
- Path: Firewall > Aliases > IP
- Name: SQUID_CONNECTED_NETWORKS

Floating Rule Configuration
- Path: Firewall > Rules > Floating
- Quick: Checked (Apply immediately)
- Interface: [MGMT, APP, DB]
- Direction: In
- Protocol: TCP
- Destination Port: 3128
- Description: "Allow internal segments to reach Squid Proxy"

Client Integration
```vim
vim /etc/environment
http_proxy="http://10.0.60.13:3128/"
https_proxy="http://10.0.60.13:3128/"
no_proxy="localhost,127.0.0.1"
HTTP_PROXY="http://10.0.60.13:3128/"
HTTPS_PROXY="http://10.0.60.13:3128/"
NO_PROXY="localhost,127.0.0.1"
```

```vim
source /etc/environment # Apply changes
Package Manager Proxy Configuration
Ubuntu Server (APT)
File: /etc/apt/apt.conf.d/99proxy
Acquire::http::Proxy "http://10.0.60.13:3128/";
Acquire::https::Proxy "http://10.0.60.13:3128/";

Fedora Server (DNF)
File: /etc/dnf/dnf.conf
proxy=http://10.0.60.13:3128
```

## REQUired Documents
/etc/squid.conf
```vim
# --- NETWORK PARAMETERS ---
http_port 3128
visible_hostname squid.example.local

# --- NETWORK SEGMENTATION (ACLs) ---
acl MGMT src 10.0.10.0/24
acl CORP_LAN src 10.0.20.0/24
acl DMZ src 10.0.30.0/24
acl APP src 10.0.40.0/24
acl DB src 10.0.50.0/24
acl SEC_OPS src 10.0.60.0/24
acl GUEST src 10.0.70.0/24
acl localhost src 127.0.0.1/32

# --- TARGETS (Whitelists) ---
acl acl_mgmt_dst dstdomain "/etc/squid/whitelists/whitelist_mgmt.txt"
acl acl_corp_dst dstdomain "/etc/squid/whitelists/whitelist_corp.txt"
acl acl_dmz_dst dstdomain "/etc/squid/whitelists/whitelist_dmz.txt"
acl acl_app_dst dstdomain "/etc/squid/whitelists/whitelist_app.txt"
acl acl_db_dst dstdomain "/etc/squid/whitelists/whitelist_db.txt"
acl acl_sec_dst dstdomain "/etc/squid/whitelists/whitelist_sec.txt"

# --- PORTS ---
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 443
acl CONNECT method CONNECT

# --- ACCESS RULES ---
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

http_access allow localhost
http_access allow MGMT acl_mgmt_dst
http_access allow CORP_LAN acl_corp_dst
http_access allow DMZ acl_dmz_dst
http_access allow APP acl_app_dst
http_access allow DB acl_db_dst
http_access allow SEC_OPS acl_sec_dst

http_access deny all

# --- CACHE & LOG SETTINGS ---
cache_mem 128 MB
maximum_object_size_in_memory 2 MB
cache_dir ufs /var/spool/squid 1000 16 256
maximum_object_size 10 MB
access_log /var/log/squid/access.log squid
cache_log /var/log/squid/cache.log

# --- UBUNTU SPECIFIC ---
error_directory /usr/share/squid/errors/en
coredump_dir /var/spool/squid

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320

```

whitelist_mgmt.txt

```vim
vim /etc/squid/whitelists/whitelist_mgmt.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
download.rockylinux.org
dl.rockylinux.org
vault.rockylinux.org
dl.fedoraproject.org
download.fedoraproject.org/pub/epel
mirrors.fedoraproject.org
.rockylinux.org
.fedoraproject.org
.kernel.org
.isc.org
.ansible.com
.pypi.org
.pythonhosted.org
.launchpadcontent.net
.canonical.com
.cloudflare.com
```

whitelist_corp.txt 

```vim
vim /etc/squid/whitelists/whitelist_corp.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
```

whitelist_dmz.txt 

```vim
vim /etc/squid/whitelists/whitelist_dmz.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.nginx.org
.haproxy.org
```

whitelist_app.txt 

```vim
vim /etc/squid/whitelists/whitelist_app.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.kubernetes.io
.docker.com
.io.containerd
```

whitelist_db.txt 

```vim
vim /etc/squid/whitelists/whitelist_db.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.mariadb.org
.postgresql.org
```

whitelist_sec.txt 

```vim
vim /etc/squid/whitelists/whitelist_sec.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.suricata-ids.org
.elastic.co
.prometheus.io
.grafana.com
```

create  these files wita script

```sh
#!/bin/bash
cat <<'EOF' > /etc/squid/whitelists/deneme1.txt
.ubuntu.com
.archive.ubuntu.com
EOF
cat <<'EOF' > /etc/squid/whitelists/deneme2.txt
.ubuntu.com
.archive.ubuntu.com
EOF
```




# DIRECTORY SERVICES-SERVER 

sudo dnf update -y && sudo reboot
sudo dnf install freeipa-server freeipa-server-dns -y
sudo ipa-server-install

fedora server kur. static ip ve dns konfig yap sonra;


/tmp icinde ki ipa.system.records.hmei6av6.db dosyasinin icerigini kopyala ve dns server da bind/zones icinde  db.example.com  dosyasiin götüne kopyala. 
Sonra id1 serverda firewall kurallariyla port lari ac; 

```bash
firewall-cmd --list-ports 
firewall-cmd --add-port={123,88,464}/udp --permanent
firewall-cmd --add-port={80,442,689,636,88,464}/tcp --permanent
sudo firewall-cmd --add-service={freeipa-ldap,freeipa-ldaps,kerberos,dns} --permanent
sudo firewall-cmd --reload
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



suricata kuracagiz. ortamda freeipa , freeipa-dns-server var. önde pfsense firewall var. Nexus proxy sunucudan paketler cekiliyor. simdi SEC sanal aginda 10.0.60.11 statik ip li rocky linux sunucuya suricata kuracagiz. ortandaki tüm makinalarin üzerindeki  isletim sistemi Rocky  linux 10.1.

Ne yapilacaksa adim adim yapilacak. her adimda ikiden fazla adim olmayacak . benden onay almadan diger adima gecmeyeceksin.  Ön ce ne anladigini anlat. Yanlis anlama olmasin. baska ihtiyac duydugun bilgi varsa omlarida söyle.


# SURICATA IDS INSTALLATION AND CONFIGURATION

System Preparation and Permissions

sudo chown -R suricata:suricata /var/log/suricata /var/lib/suricata /run/suricata
sudo chmod -R 750 /var/log/suricata
sudo chmod -R 770 /var/lib/suricata
sudo chmod -R 770 /run/suricata


Creating Test Signatures: Create a manual rule 
File: /var/lib/suricata/rules/suricata.rules
Content:
alert icmp any any -> any any (msg:"TEST: Ping Detected"; sid:1000001; rev:1;)


Set binary capabilities:
sudo setcap cap_net_raw,cap_net_admin,cap_ipc_lock+ep /usr/sbin/suricata


Test the Configuration for syntax errors before starting the service.
sudo suricata -T -c /etc/suricata/suricata.yaml -v
send ping packets from an  other  client  to suricata server

Reload and Start Service:
sudo systemctl daemon-reload
sudo systemctl enable suricata
sudo systemctl start suricata


Check if logs are being generated:
ls -lh /var/log/suricata/fast.log

Monitor logs in real-time:
tail -f /var/log/suricata/fast.log



The Ansible vocabulary¶
The management machine: the machine on which Ansible is installed. Since Ansible is agentless, no software is deployed on the managed servers.
The managed nodes: the target devices that Ansible manages are also referred to as "hosts." These can be servers, network appliances, or any other computer.
The inventory: a file containing information about the managed servers.
The tasks: a task is a block defining a procedure to be executed (e.g., create a user or a group, install a software package, etc.).
A module: a module abstracts a task. There are many modules provided by Ansible.
The playbooks: a simple file in yaml format defining the target servers and the tasks to be performed.
A role: a role allows you to organize the playbooks and all the other necessary files (templates, scripts, etc.) to facilitate the sharing and reuse of code.
A collection: a collection includes a logical set of playbooks, roles, modules, and plugins.
The facts: these are global variables containing information about the system (machine name, system version, network interface and configuration, etc.).
The handlers: these are used to cause a service to be stopped or restarted in the event of a change.




suricata

```bash
mkdir -p /opt/suricata-central/rules # Create directory for central rule storage

echo 'alert icmp any any -> any any (msg:"CENTRAL: ICMP Test Detected"; sid:1000001; rev:1;)' > /opt/suricata-central/rules/local.rules # Create a sample rule file with English message for testing
```

/opt/suricata-central/docker-compose.yml
```yaml
version: '3.8'
services:
  rules-server:
    image: nginx:1.26-alpine
    container_name: suricata-rules-server
    ports:
      - "44380:80"
    volumes:
      - /opt/suricata-central/rules/suricata.rules:/usr/share/nginx/html:ro
    restart: always

  suricata-update:
    image: jasonish/suricata:latest
    container_name: suricata-update
    volumes:
      - /opt/suricata-central/rules:/var/lib/suricata/rules
    command: >
      suricata-update
      --output /var/lib/suricata/rules/suricata.rules

```
docker compose up -d
docker compose run --rm suricata-update


```bash 
docker run --rm -v /opt/suricata-central/rules:/var/lib/suricata/rules jasonish/suricata:latest suricata-update --local /var/lib/suricata/rules/local.rules
```

verifixation 

ls -F /opt/suricata-central/rules/ # Dosyaların varlığını gör


curl -I http://localhost:44380/suricata.rules  # HTTP servisinin kuralı servis ettiğini gör 


curl -s http://localhost:44380/suricata.rules | grep "CENTRAL"  # Kendi kuralının dosya içinde olduğunu gör


central  server  ist schon installiert. 

## Sensür side installation and configuration. 


mkdir -p /opt/suricata-sensor/config /opt/suricata-sensor/logs

touch /opt/suricata-sensor/config/suricata.yaml
```yaml

```

docker compose file 
services:
  suricata:
    image: jasonish/suricata:latest
    container_name: suricata-sensor
    network_mode: host
    cap_add:
      - NET_ADMIN    # Allows managing network interfaces and setting promiscuous mode.
      - NET_RAW      # Enables capturing raw packets directly from the network interface.
      - SYS_NICE     # Allows setting process priority to prevent packet drops under load.
    volumes:
      - /opt/suricata-sensor/config/suricata.yaml:/etc/suricata/suricata.yaml
      - /opt/suricata-sensor/logs:/var/log/suricata
      - /opt/suricata-sensor/rules:/var/lib/suricata/rules
    restart: always