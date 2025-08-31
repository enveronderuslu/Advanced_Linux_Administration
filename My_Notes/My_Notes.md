```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@192.168.178.115
```

``` bash
ls ; date
Sample_file  myapp         
Fri Aug 15 09:01:39 PM CEST 2025
```
&&  baglacida ; gibi kullanilabilir fakat komut1 && komut2 farkli anlama gelir. birinci calisr isi biterse ikinci calisir. ; de birbirinden bagimsiz calisir.
benzer sekilde komut1 || komut2 var. Bu defa sol taraf hata dönerde sag taraf calisir-  sol taraf calisirsa sag calismaz. XOR gibi 

yine command & ie komut arka planda calisir
# Red Hat Linux Notes
# Linux System Basics – Quick Notes
sudo derdinden kurtulmak istiyorum:
Hedef makinada şu komutla sudoers dosyasına özel bir kural ekle:

```bash
sudo visudo
test ALL=(ALL) NOPASSWD: ALL
# Eğer sadece reboot komutu için yetki vermek istersen:
test ALL=(ALL) NOPASSWD: /sbin/reboot
```
## System and Hardware Info

```bash
hostnamectl  # Shows full system metadata 
lscpu  # Displays CPU architecture and info  
lsblk  # Lists block devices (disks, partitions, etc.) 
free -m  # Shows memory (RAM) usage in MB 
df -kh # Displays all mounted partitions and their usage in human-readable format
date  # Displays current date, time, and timezone (localization info)
whoami  # Shows current logged-in user 
who  # Users currently connected to the system
``` 
## Monitoring Tools 
- `htop`  # A better, interactive version of `top` with a cleaner UI
- `top` → press `Enter`, then `Shift + M`  
  Sorts processes by memory usage
- `vmstat`  # Reports current memory and system activity
- `iotop`  # Displays real-time disk read/write by processes
- `nmon`  # Powerful monitoring tool for all system statistics

## Aliases & Bash Customization
Each user has their own `.bashrc` file. To apply changes, run:  
`source ~/.bashrc`
Sample aliases :
```bash
alias sysupdate='dnf -y update'
alias c='clear'
alias l='ls -laFtr  --color=no'
alias ping='ping -c 5'
alias ports='netstat -tulanp'
```
Changing the System Hostname: Edit the file directly 
`sudo vim /etc/hostname + reboot` or `sudo hostnamectl set-hostname newname`
Script Logging: Save terminal output ` script deneme.txt # Type exit to stop`

# System Architecture and Boot Process
## Boot Process
 - BIOS/UEFI initializes hardware and loads the bootloader.
 - GRUB (GRand Unified Bootloader) presents boot options and loads the kernel.
 - Kernel Initialization.
 - init/Systemd launch essential services and bring the system to a usable state.

## systemd Overview

systemd, modern Linux sistemlerinin temelini oluşturan bir sistem ve servis yöneticisidir. Eskiden kullanılan init sisteminin yerini almıştır. Temel olarak şunları yapar:
 - Sistemi Başlatma (Boot): Cekirdekten sonra ilk çalışan süreçtir (PID 1). Sistemi kullanıma hazır hale getirmek için gerekli servisleri ve süreçleri başlatır. Bunu paralel olarak yaparak sistem açılış süresini önemli ölçüde kısaltır.
 - Servis Yönetimi: Sistemdeki tüm servisleri (web sunucuları, veritabanı sunucuları, ağ servisleri usw). 
 - Bağımlılık Yönetimi: Servisler arasındaki bağımlılıkları takip eder ve servislerin doğru sırada başlatılmasını sağlar. Bir servis çalışabilmek için başka bir servisin çalışıyor olmasına ihtiyaç duyabilir. 
 - Kaynak Yönetimi: Sistem kaynaklarını (CPU, bellek ...) yönetitr izler kontrol eder. 
 - Günlükleme (Journaling): Sistem olaylarını ve servislerin çıktılarını merkezi bir yerde (journald) toplar. `journalctl`  komutu ile bu günlüklere erişilebilir.
 - Diğer Özellikler: Zamanlanmış görevler (systemd.timer ile cron yerine), ağ yapılandırması (systemd-networkd), kullanıcı oturum yönetimi (systemd-logind) gibi birçok ek özelliği de bünyesinde barındırır.
```bash
systemd-analyze + blame # makinenin baslamasi icin süre + detaylat 
/lib/systemd/system # services are here
```
### .target .service dosyalari
.target uzantılı dosyalar, SysVinit’teki runlevel kavramının modern  karşılığıdır. .service dosyaları bireysel servisleri tanımlar. .target dosyaları ise bu servisleri bir araya getirip topluca yönetir. `/lib/systemd/system/` veya `/etc/systemd/system/` icinde bulunurlar. `.service` dosyası bir servisin kendisini tanımlar. İçinde hangi binary’nin çalıştırılacağı, hangi kullanıcıyla çalışacağı, ne zaman yeniden başlatılacağı gibi bilgiler olur. Örneğin: `myhttp.service` dosyasini olusturalim. 
```ini
[Unit]
Description= Python HTTP Server
[Service]
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=nobody
[Install]
WantedBy=multi-user.target
```
Bu dosya kaydedilip `systemctl enable myhttp.service` denildiğinde servis açılışta otomatik başlar.

.target dosyası ise doğrudan bir servis tanımlamaz; sadece bir grup mantıksal hedef sunar. Örneğin:
```ini
[Unit]
Description=Custom Services Target
Requires=myhttp.service
Requires=nginx.service
After=network.target
```
Bu custom.target çağrıldığında myhttp.service ve nginx.service beraber yüklenir. default .target dosyalari:
--- multi-user.target
(ağ servisleri, çoklu kullanıcı, SSH, cron gibi servisleri çalıştırır. systemctl status multi-user.target

--- graphical.target GUI içeren sistemler için kullanılır. 

# Package Management with YUM and DNF

```bash
dnf install package-name #Installing packages:
dnf update # Updating packages: 
dnf remove package-name # Removing packages: 
rpm -qi package-name # Querying package info: 
custom .repo files in /etc/yum.repos.d/ # Managing repositories: 
dnf clean all # it deletes Metadata cache (depo bilgileri), Paket önbelleği (indirilen .rpm dosyaları), Geçici  dosyalar ve depo verileri
rpm -qa | grep -i libre* ; dpkg -l  # shows the installed packages
dnf -y remove libreoffice*
```
 
### ORPHAN PACKAGES 
A paketi B paketine bagli . B yi kaldirdin. A atil kaldi. iste A ya Orphan package denir. How to remove?
```bash
dnf repoquery --unneeded
dnf remove $(dnf repoquery --unneeded -q)
```
Snap, Canonical (Ubuntu'nun geliştiricisi) tarafından geliştirilen, dağıtımdan bağımsız çalışan bir paket sistemidir. Uygulamalar kendi bağımlılıklarıyla birlikte paketlenir. `sudo snap install App1`

### Case Study
	
sudo  apt install google-chrome-stable_current_amd64.deb
E: Unable to locate package google-chrome-stable_current_amd64.deb
apt, bu komuttaki "google-chrome-stable_current_amd64.deb" ifadesini, bir paket deposundaki paket ismi sanıyor. 
`sudo apt install Firefox` komutunda Dogru calisir. Ama sen aslında elindeki yerel bir dosyayı kurmaya çalışıyorsun. Bu yüzden sistem, Benim depolarımda `google-chrome-stable_current_amd64.deb` diye bir paket yok diyor. Ve hata veriyor. apt, .deb dosyalarını paket deposu (package repository) adı gibi algılar. Bu yüzden "Unable to locate package" hatası verir.
.deb dosyası ile çalışmak için uygun değil.
`sudo dpkg -i  google-chrome-stable_current_amd64.deb`  -> Doğru kullanım

`sudo apt install firefox` dediğinde, apt markete gider, raftan firefox paketini bulur ve kurar. 
3. apt = Market görevlisiakip eder.
4. deb dosyası = Poşet içindeki ürün `sudo dpkg -i ürün.deb`
5. baska yol: dosyayi indirdigin yerde terminali ac. ` apt install ./sample.deb` yazsan direk calisacakti Aklini s*keyim

# Filesystem Management

## Special Permissions

| Bit      | Kullanım Yeri | Etkisi                                                                  | İlgili Komut       | `ls -l` Göstergesi |
| -------- | ------------- | ----------------------------------------------------------------------- | ------------------ | ------------------ |
| `setuid` | **Dosya**     | Dosya, **sahibinin yetkileriyle çalışır**                               | `chmod u+s dosya`  | `rws` (x varsa `s`, yoksa `S`) |
| `setgid` | **Dosya**     | Dosya, **grup sahibinin yetkileriyle çalışır**                          | `chmod g+s dosya`  | `rwxr-s` (x varsa `s`, yoksa `S`) |
| `setgid` | **Klasör**    | Klasöre eklenen dosyalar **aynı grup** ile oluşturulur                  | `chmod g+s klasör` | `rwxr-s`            |
| `sticky` | **Klasör**    | Klasördeki dosyalar, **sadece sahibi veya root tarafından silinebilir** | `chmod +t klasör`  | `rwxrwxrwt`        |

 
# User and Group Management

useradd, groupadd
userdel <user> home directory silinmez
userdel -r <user> home directory silinir
usermod -G <DROUP> <USER> (diger gruplardan cikarir. kendi ismindeki grup korumur)
usermod -aG <GROUP> <USER> (diger gruplarda kalmaya devam eder)
visudo /etc/sudoers dosyasini acar- who veya users makineyi o an kullanan kullanicilari verir

`etc/passwd` user accountlarla ilgili bilgiler
`etc/shadow` encrypted password ler burada.

## Password Policies

PASSWORD AGING: chage -m mindays -M maxdays -d lastday
`sudo nano /etc/logindefs` dosyasinda bu sayilari düzelt. Bu yeni sistemlerde artik yok. Peki ne var: ` /etc/security/pwquality.conf` yine FAILED LOGINLER ICIN `/etc/security/faillock.conf` 

### Using `ps`

`ps aux | grep  ssh` bununla tüm ssh processlerini ve PID lerini görürsün

ctrl + z ekrandaki islmei arkaya atar
jobs ile bu islemleri görürsün
%1 sana arkada calisan 1 numarali processi getirir
fg veya bg foreground background ta calistirir

### SYSTEM MONITORING
Using `top` and `htop`

`top -u user1` user1 ne kullaniyor sadece bunu gösterir
top 

| Kolon     | Açılım               | Açıklama  |
| --------- | -------------------- | ------------------ |
| `PID`     | Process ID           | İşlem kimliği  |
| `USER`    | User                 | İşlemi başlatan kullanıcı |
| `PR`      | Priority             | İşlem önceliği |
| `NI`      | Nice value           | Nice islem önceliğini belirler |
| `VIRT`    | Virtual Memory       | Sanal bellek kullanımı (MB/KB) |
| `RES`     | Resident Memory      | Fiziksel RAM kullanımı   |
| `SHR`     | Shared Memory        | Paylaşılan bellek miktarı  |
| `S`       | State                | İşlem S: uyku, R: çalışıyor, Z: zombie |
| `%CPU`    | CPU Usage Percent    | İşlemin CPU kullanım yüzdesi   |
| `%MEM`    | Memory Usage Percent | İşlemin RAM kullanım yüzdesi   |
| `TIME+`   | CPU Time (total)     | İşlemin toplam CPU süresi |

***dmesg*** hardware ile ilgili hersey burada
| Section                | Description    |
| ---------------------- | ----------------------- |
| Boot             | Messages about system initialization BIOS, ACPI, EFI |
| CPU and Memory   | Information about processors, cores, and memory   |
| Disks and I/O    | Detection and status of storage devices `sda, nvme,usb`|
| Ntwrk Interfaces | Initialization of network devices `eth0, wlan0, enpXsY` |
| USB Devices      | Connection/disconnection messages for USB      |
| Driver Errors    | Kernel messages indicating driver failures `error, fail`|
| Kernel Warnings  | issues, crashes `WARNING, BUG, panic, call trace` |
| Module Loading   | Messages about kernel modules loaded `modprobe, insmod`|
| Timestamps       | Elapsed time since boot, shown as `[ XX.XXXXXX ]` in each line.|

pratik filtreleme 
```bash
dmesg | grep -i error       # Hata mesajlarını bulur
dmesg | grep usb            # USB ile ilgili mesajları listeler
dmesg | grep -i fail        # Başarısızlıklarla ilgili satırlar
dmesg | grep eth            # Ethernet veya ağ arayüzü sorunları
```

## Managing Processes
###  `kill`, `killall`

w shows all current sesions
```bash 
pgrep -l -u bob # bob isimli user la ilgili processes
``` 

```bash
pkill -SIGKILL -u newuser # user ile ilgili tüm prosesleri kill yapar
```

```bash
pstree -p newuser # proses agaci
```

###  `nice`, `renice`

nice : run a program with modified scheduling priority.High priority icin negatif degerler verilir. -20 = en yüksek öncelik. negatif degeri sadece adminler verebilir
19 = en düşük öncelik (sisteme en az yük olur)

renice komutuyla siralamayi degistirirsin

## Scheduled Tasks
### `cron`

Application=Service: Script list of instructions. 
Process: when you start a service(app) it starts a Process and process id
Daemon: etwas continuously runs in background doesnt stops. it is also a process

# Networking
netstat -tunp

| Alan                 |Açıklama    |
| -------------------- | -------------------------- |
| **Proto**            | Protokol türü: TCP, UDP, RAW gibi.     |
| **Recv-Q / Send-Q**  | Alınan ve gönderilen veri kuyrukları. |
| **Local Address**    | Yerel IP adresi ve portu. Hangi portun hangi IP'de |
| **Foreign Address**  | Bağlı olan uzak IP ve port. Hangi istemcinin bağlı  |
| **State**            | Bağlantı durumu: `LISTEN`, `ESTABLISHED` vs.        |
| **PID/Program name** | (Bazı sürümlerde) Bağlantıyı kullanan işlem adı ve PID |

***DIKKAT***

| Durum              | Ne Anlama Gelir?             |
| ------------------ | ---------------------------- |
| **LISTEN**         | Port dinlemede, gelen bağlantıları kabul etmeye hazır. |
| **ESTABLISHED**    | Aktif bir bağlantı var |
| **CLOSE\_WAIT**    | Karşı taraf kapattı ama sizin taraf hala kapatmadı |
| **TIME\_WAIT**     | Bağlantı kapatıldı ama bir süre daha beklemede |
| **SYN\_SENT / SYN\_RECV** | TCP bağlantısı kurulmaya çalışılıyor.  |

*** CASE STUDY ***
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

/etc/resolv.conf ta search yahoo.com yazdiginda artik subdomain leri uzunuzun yazmana gerek kalmaz. artik curl news  yazdiinda direk curl news.yahoo.com anlasilir

dig @4.2.2.2 google.com -> google.com alan adının IP adresini, 4.2.2.2 DNS sunucusunu kullanarak sorgular.
/etc/resolv.conf 

Örnek içerik:
passwd:     files sss
group:      files sss
hosts:      files dns
Anlamı:
passwd: files sss → Önce /etc/passwd, sonra SSSD (örn. LDAP) kullanılacak.
hosts: files dns → IP/hostname çözümlemesinde önce /etc/hosts, sonra DNS kullanılacak.

nmcli temiz network device adress bilgisi veriyor
nmcli connection show ens23 ens23 ün detaylarini gösterir 
nmcli connection delete ens23 bu adaptörü siler
nmcli connection modify ens224 connection.interface-name "wired connection 3"
cnnection.interface-name kismini show ens23 komutunda görüyorsun ve tab ile geliyor
`nmtui` nm-connection-editor (GUI) 

What is the loopback device? localhost
NIC bonding: Combining multiple NICs together

ss COMMAND
It is a faster and more modern replacement for netstat.
```bash
ss -tuln         # Show listening TCP/UDP ports with numeric addresses
ss -s            # Display summary statistics
ss -plnt         # Show listening TCP sockets with process info
```
Copy a file from a server to another; `scp *.txt  kali@192.168.X.X:/kali/Desktop` 
timedatectl set-timezone Europe/Berlin
`traceroute www.google.com` . Bunun dinamik olani real time olani mtr dir.  `mtr www.google.com`. 

## DNS Setup
`/etc/resolve.conf ` Dns gibi calisir

PAM MATRIX DIYE BISEY VAR ONA BI BAK

## Firewall Configuration with `firewalld`

# Storage and Disk Management

fdisk -l gives the list of disks 
fdisk /dev/nvme0n2  bu bizim VMWare de sonradan ekledigimiz disk 
df -h disk usage

### MOUNT ETME ISLEME 
 mkdir -p /home/enver/Desktop/disk2 
 mkfs.ext4 /dev/nvme0n2   # önce formatladim
 mkdir -p /home/enver/Desktop/disk2 # diski mount edecegim dosyayi olusturdum
 -p ; aradaki parent klasörler yoksa onlarida olusturur
 mount /dev/nvme0n2 /home/enver/Desktop/Disk2   # simdide mount ettim
 Gparted  disk islemlerini komutsuz arayüz ile hallet

 Persistent Mounts using `/etc/fstab`

# Security and SELinux
## Basic Security Practices

LINUX OS HARDENING

 /etc/login.defs
 /etc/pam.d/system-auth 
 
- Remove  un-wanted Packages
 rpm -qa kurulu tüm paketleri verir (Debian da "dpkg -l")
 bir paketi kaldirirken dependiec  kismini dikkat et

 /etc/ssh/sshd_config
 change port enable 
 PermitRootLogin no yap. kimse root olarak baglanamasin
 systemctl restart sshd yapmayi unutma
- Enable Firewall (firewalld)
 firewall-config bir GUI acar
 firewall-cmd  --help
- Enable Selinux
 Securits Enhanced linux 
 it  is a projeckt of NSE 
 Damit kann man permissions von Prozesse oder Serveces ändern
 sestatus ile kontrol edebilirsin. 
 root@rocky sysconfig]# pwd
/etc/sysconfig/selinux burada detaylar var
- Chande listening Services Port numbers
 mesela ssh portunu 22 den baska bisey yapabilirsin
- Keep your OS up to date
 

## File and Directory Permissions

head etwas.txt shows first 10 line of the file
tail etwas.txt shows last 10 line of the file
tail -n 20 etwas.txt
sudo tail -f  /var/log/syslog eklendikce yenileri  görürsün

icinde folder1 folder2 folder3 yazan bir folder.txt dosyasi hazirla. cat folder.txt | mkdir  calistirdigin zaman bulundugun klasörde folder1 folder2 folder3 dosyalari olussur . xargs, komut satırında bir komutun argümanlarını dışardan (genellikle stdin'den) alarak çalıştıran bir yardımcı programdır.
Kısaca: Veriyi alır, komutlara argüman olarak dönüştürür.

command 2> /dev/null  özellikle komut ciktisinda cok fazla eror olacaksa bu erorlar temizlenmis olur

find  / -name *.doc 2> /dev/null
sudo updatedb sonra locate deneme.txt  daha hizli bulur
grep -c -i Ali isimleer txt   dosyada ali isminin kac kere gectigini -c , büyük Kücük harf hassasiyetrinden kurtulmayi -i sagllar. 

grep -r search in subdirectories
grep -r -i ebenin* recursively tüm dosya isimleri ve iceriklerinde ebenin kelimesiyle baslayan kelemeleri bulur
-r  -i yerine -ri yazabilrsin

egrep "abc|xyz"  abc veya xyz bulacak
egrep "^1[0-2]"  ^ satir basinda 10, 11, 12 ile baslayanlar
sha356sum abc.txt

locate tüm file Lari bir database icinde arar ve süper hizlidir. Fakat sudo updatedb yapmalisin

whereis tüm hardawre da aramaz path de arar 
which  in farki direk command in nerede calistigini verir
find / -name *.pdf 2> /dev/null
find / -size +100M 2> /dev/null
find / -perm /g=w,o=w 2> /dev/null w Hakki olan gruplar ve other people bulunur


chown change owner
sudo chown cemsit deneme.txt dosyanin owner ini cemsit yapar
sudo chown -R cemsit klasor  hem klasorun Hemde altinda ne varsa hepinin sahabini degistirdi
sudo chown -R  cemsit:cemsit klasor/ hem kullanici hem grup degisti

-s (setuid veya setgid) argümanı, bir dosya çalıştırıldığında:
setuid (user): Komut, dosya sahibinin yetkileriyle çalışır.
setgid (group): Komut, dosya grubunun yetkileriyle çalışır.
Genellikle chmod u+s veya chmod g+s şeklinde kullanılır.

chmod u+s /usr/bin/example

Bu komut, example dosyasına setuid verir.
Artık bu dosyayı çalıştıran herkes, onu sahibi gibi (root olabilir) çalıştırır.

chmod g+s /usr/bin/example
Bu komut, example dosyasına setgid verir.
Artık dosyadan oluşturulan alt dosyalar, dosyanın grubuna ait olur.

Bir dizine setgid verildiğinde, o dizin içinde oluşturulan tüm dosya ve klasörler, otomatik olarak dizinin grubuna ait olur.

Normalde ne olurdu?
Varsayılan olarak, bir kullanıcı bir dizine dosya eklediğinde, o dosya kullanıcının aktif grubuna ait olur.

mkdir paylasim
chown :gelistirici paylasim
chmod g+s paylasim
Bu durumda:

mkdir paylasim
chown :gelistirici paylasim
chmod g+s paylasim

paylasim klasörüne kim dosya eklerse eklesin,
Eklenen dosyalar gelistirici grubuna ait olur.
Bu yöntem, ortak çalışma dizinlerinde grup sahipliğini sabit tutmak için kullanılır.


umax file olusturulunca otomatik verilecek yetkileri belirler

cat /etc/fstab  file system table

setfacl -m u:cemsit:rw deneme.txt enver kullanicisinin üzerinde 
Hakki olan deneme.txt dosyasina bir user daha atadim (gruba hak taniyacaksan u yerine g yaz)
gertfacl deneme.txt ile detaylari görürsün.

directory icinde setfacl uygulanir fakat inherited olmasi icin :

sudo setfacl -m u:user1:rw reports/ bununla reports dosyasininicindekilere inherit edemezsin. 

sudo setfacl  -d -R -m  u:user1:rw reports/ yaparsan asagi Dogru gider

ldd library daemon dependecy 
ldd /bash/vim vm applicationu hangi kütüphaneleri kullaniyor
/home/enver de -local dosyasi var bunun icinde shred dosyalari saklamak daha dogru.

sudo ldconfig -n /home/enver/.local/lib 

ldconfig: Paylaşımlı kütüphaneleri (.so dosyaları) tarar ve sistemin kullanması için yeni/özel kütüphane yollarını günceller.

-n: Sadece belirtilen dizini (/home/enver/.local/lib) işler.
(Yani /etc/ld.so.conf dosyasını veya diğer yolları dikkate almaz.)

/home/enver/.local/lib: Taratılacak özel kütüphane klasörüdür.

Ne işe yarar?
Bu komut, /home/enver/.local/lib dizininde bulunan kütüphaneleri sistemin tanımasını sağlar, böylece burada bulunan .so dosyaları çağrılabilir hale gelir.
Kullanıcı kendi yerel kütüphanelerini derleyip kullanmak istediğinde bu komut sıkça kullanılır.


ls .. what is in the parent dirctory

ln mainfile.txt  sonradanolusanfile.txt  link yapma  herhangibirinde yaptigin ddegisiklik digerinde de olusur

find / -perm +rwx  rwx hakkinna sahip file Lari arayacak
find /usr  -group sales
find / size +2M
find komutu cok masraflidir bunnun yerine locate daha iyi. (sudo updatedb) satabase  i kullandigi icin daha Rahat is görür

whoami ve arkasindan id  command sonucta 100 l id root user olur


file creation default icin umask degeri kullanilir. Mesela 022 aslinda 755 tir. umask degeri 777 den cikarilir

sudo du -h --max-depth=1 /  2>/dev/null  root tan itibren bir dosya aagiya Kadar ne vatsa onlaeri ve giskusage leri bulur


ls -F hlasör dosa executabl  durumlarini verir
link olusturma ln -s testdir/file1.txt link1
useradd  newuser
passwd newuser
rm -rf silliklanmadan herseyi siler 
tail -n 1 /etc/group veya /etc/passwd (eklenen son user/group görürsün)

umask set the defaults of file/directory  creation 
umask /etc/bashrc icinde bu degeri degistirebilirsun



### `getenforce`, `setenforce`
### `semanage`, `restorecon`, `getsebool`

# System Monitoring and Performance
### `top`, `iotop`, `vmstat`, `sar`
## Reading Logs with `journalctl`

# Troubleshooting and Recovery
## Troubleshooting and Recovery

###  What Is Troubleshooting?

Thi nk of your Linux system like a car. Sometimes it won’t start, or it makes weird noises. Troubleshooting is like being a mechanic — you observe the symptoms, identify the problem, and fix it.

Troubleshooting in Linux means:

- Detecting what’s wrong
- Diagnosing the cause
- Applying a fix
- Testing if the fix worked

Recovery is what you do **after something breaks** — like when your system doesn’t boot, or a service crashes.
LOG MONITORING 
Log directory /var/log 
boot reboots issues 
chronyd=NTP 
cron
maillog
secure   all login logout activities
tail -f secure dinamik olarrak log penceresi acik kalir 
messages important to monitor system  activities
httpd apache application log 
---

### Common Troubleshooting Tools and Techniques

| Tool/Command         | Purpose                                      |
|----------------------|----------------------------------------------|
| `journalctl`         | View system logs                             |
| `dmesg`              | View kernel messages                         |
| `systemctl status`   | Check status of systemd services             |
| `top`, `htop`        | Monitor CPU and memory usage                 |
| `ps aux`, `pstree`   | View running processes                       |
| `strace`             | Trace system calls of a process              |
| `netstat`, `ss`      | Monitor network connections                  |
| `ping`, `traceroute` | Check connectivity                           |
| `lsblk`, `df`, `mount` | Diagnose storage and mount issues          |
load avarage
uptime veya cat /proc/loadavg ile bulunur. son 1, 5 ve 15 dakikalik load avarage (cpu) kullanimini verir 
lscpu da degerleri verir 
---

### Example: A Service Isn’t Starting

Let’s say your Apache web server isn’t starting.

Step-by-step:

1. **Check service status:**
   ```bash
   systemctl status httpd
   ```

2. **View logs:**
   ```bash
   journalctl -xeu httpd
   ```

3. **Look for errors** like:
   ```
   Permission denied
   Port already in use
   SELinux denial
   ```

4. **Check configuration syntax:**
   ```bash
   apachectl configtest
   ```

5. **Fix the issue and restart:**
   ```bash
   systemctl restart httpd
   ```

---

### Troubleshooting Boot Issues

Sometimes your system fails to boot. Here’s what to try:

### Boot into Rescue Mode or Emergency Mode

1. Reboot the system.
2. At the GRUB screen, edit the kernel line:
   - Add `systemd.unit=rescue.target` or `emergency.target`.

This gives you a **minimal shell** for recovery.

### Common Boot Problems

| Symptom                              | Possible Cause                     |
|--------------------------------------|------------------------------------|
| Kernel panic                         | Bad initramfs or hardware issues   |
| Hanging after grub                   | Missing root device                |
| "Cannot mount root"                  | Filesystem issues or UUID mismatch |
| Black screen                         | Graphics driver problem            |

### Fixing with Dracut

If initramfs is broken:

```bash
dracut --force
```

Or regenerate for a specific kernel:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

---

### Recovering Root Password

If you forgot the root password:

1. Reboot into GRUB menu.
2. Edit kernel line (`e`), append:
   ```
   rw init=/bin/bash
   ```
3. After booting:
   ```bash
   passwd
   ```
4. Then:
   ```bash
   exec /sbin/init
   ```

---

### Reinstalling or Repairing GRUB

If the system shows a `grub>` prompt or cannot find the bootloader:

Boot from a live CD/USB:

```bash
mount /dev/sdaX /mnt
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub2/grub.cfg
exit
reboot
```

### System Running Slow? Here’s What to Check

1. **CPU Usage:**
   ```bash
   top
   ```

2. **Memory Usage:**
```bash
free -m
```

3. **Disk Space:**
```bash
df -h
```

4. **I/O Wait:**
```bash
iostat
```

5. **Zombie Processes:**
```bash
ps aux | grep 'Z'
```
### Application Crashes

When an app crashes:

- Use `journalctl` to see logs
- Use `strace` to trace it:
  ```bash
  strace ./appname
  ```
- Look at core dumps:
  ```bash
  coredumpctl list
  coredumpctl info <PID>
  ```

### Network Troubleshooting

1. **Check if the interface is up:**
 ```bash
 ip a
 ```

2. **Can you ping your gateway?**
```bash
ping 192.168.1.1
```

3. **Can you resolve DNS?**
```bash
nslookup google.com
```

4. **View all connections:**
```bash
ss -tunlp
```

5. **Firewall issue?**
```bash
firewall-cmd --list-all
```

###  Summary

- Troubleshooting is about identifying, diagnosing, fixing, and testing.
- Use tools like `journalctl`, `systemctl`, `ping`, and `top`.
- Boot problems often require GRUB and rescue mode techniques.
- Recovery includes repairing GRUB, fixing services, and resetting passwords.
- Learn to read logs — logs are your best friend in troubleshooting.

Practice common scenarios in a virtual machine to build confidence!

DNS problems: Server is not reaxhable
 cat /etc/hosts
 cat /etc/resolv.conf
 cat /etc/nsswitch.conf
 ping gateway
 check physical Connection
WEBsite or Application is not erreichbar
 Question: Server or sservice on it down?
 ping with ip adress or hostname
 telnet 192.168.178.x 80 port calisip calismadigini gösterir
 baglanamazsan demekki http service is not running
Can not SSK as root
 as default root connection is disabled
 /etc/ssh/ssh_config  ssh ile giderken yapilan ayarlar 
 /etc/ssh/sshd_config gelen ssh baglantilaei icin ayarlar
 mesela root olarak birisi baglanabilsinmi
 /var/log/secure  burayi tail -f ile izlersen 
 canli tüm loginleri görürsün
Can not write to a File 
 parent directory permissions 
 anotheruser works with the file
 getfacl  filename ausführliche info über file
Dusk problems 
 cat /etc/fstab  diskle ilgili bilgiler var 
 
TOP    command 
PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
PID: The Process ID — a unique number that identifies each running process.
 USER: The user who owns the process.
 PR: The process's priority for scheduling. 
 Lower numbers mean higher priority. ATAMAYI SYSTEM YAPAR 
 NI: The "nice" value, which affects the priority. 
 Ranges from -20 (highest) to 19 (lowest). KULLANICI ATAMASI
 VIRT: The total virtual memory used by the process, including code, data, and shared libraries.
 RES: The resident memory — the actual physical RAM used by the process.
 SHR: The amount of memory shared with other processes (usually from shared libraries).
 S: The current status of the process:
 R = Running
 S = Sleeping
 D = Uninterruptible sleep
 Z = Zombie
 T = Stopped
 %CPU: The percentage of CPU the process is using.
 %MEM: The percentage of physical RAM the process is using.
 TIME+: The total amount of CPU time the process has used since it started, in minutes and seconds.
 COMMAND: The name of the command that started the process.
 MiB Swap, sisteminizdeki takas alanıdir (swap). 
 RAM yetersiz kaldığında sistemin geçici olarak disk üzerinde kullandığı bellektir.
WHAT IS SWAP MEMORY?
 Swap memory is a portion of the storage 
 that used as extra virtual memory when the physical RAM is full.
 mevcut memory nin iki kati büyüklükte olmasi tavsiye edilir 
 netstat -rnv gives the IP routing table 


 pwconv, şifreleri güvenli bir şekilde saklamak için kullanılır.
 Şifreler /etc/passwd içindeyse, bu komut onları /etc/shadow'a taşır ve 
 /etc/passwd içindeki şifre alanını x olarak değiştirir.

LAST komutu sisteme login olanlari bulur 

Rollback Update Nedir? 
 Rollback update, bir sistem veya yazılım güncellemesi yapıldıktan sonra, 
 eski (önceki) sürüme geri dönme işlemidir.


sos report komutu  rhel ve rocky linux sistemlerde;
Sistem hakkında ayrıntılı teşhis bilgileri toplar:
Donanım bilgileri
Ağ ayarları
Servis durumları
Log dosyaları
Yüklü paketler
Çekirdek bilgileri vs. 

## 13.2 Managing VMs with `virt-manager`

# Useful Tools and Tips
## Common Text Editors (vim, nano)

VIM Kullanimi
yy stir yw kelime kopyalar p yapistirir
dd / de satir / üzerinde oldugu kelimeyi  siler 
/word yazarsan dosya icindeki ilk "word" kelimesini bulur. Sonra n harfine basarak
sirasiyla digerlerini bulursun. 
asagidan yukari arama: shift + g ile dosyanin sonnuna git. 
Satir numaralarin inasil gösterirsin: escape modda:set number
3 shift g  ile 3. satira gidersin
kelime degistirme: kelimenin üstüne gel cw yaz sonra yeni kelimeyi yaz

## 14.2 File Compression and Archiving
### 14.2.1 `tar`, `gzip`, `zip`
## 14.3 Searching Files
### 14.3.1 `grep`, `find`, `locate`
## 14.4 System Info Commands
### 14.4.1 `uname`, `hostnamectl`, `lsb_release`

# Appendix
## Command Cheat Sheet
SYSTEM UTILITY COMMANDS
date  uptime(1, 5, 15 dakikalarda cpu kullanimi)   
hostname   uname   ehich  
cal 11 1976
bc calculator
`cp  -pr`  klasörü icindekilerle  kopyalaar
`cat  -n`  satirlari numaralandirarak cikti verir
`cat isimler.txt| sort`    satirlari bas harflerine göre siralar
&& önce sol taraf  sonra sol calisirsa sag taraf calisir
echo -e icerdeki özel karakterleri algila
yorum satirlari: # ile baslar
Bash script te cift tirnak kullan
tmux (Terminal Multplex Command) terminal ekranini birkac bölmeye ayirir
bin & sbin :  executables for all & executanles for root  
Asagida birsey calistirilmaya calisildiginda nerelerde aranir 
PATH=/root/.local/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
mesela deneme.sh dosyasini bu dizinlerden birine tasi Sonra istedigin yerde direk calistir 
export PATH=$PATH:/home/rocky2/Skripten (Yeni path plusturacazMevcut path i $PATH ile ekledik )

Thread (İş Parçacığı)
Ne demek?
Çekirdeklerin aynı anda birden fazla işi işleyebilmesini sağlayan mantıksal işlem yolları.
Intel’de bu teknolojiye HyperThreading denir.

Ne işe yarar?
1 çekirdek = 2 thread olursa, işlemci yoğun işlerde daha fazla işi aynı anda yapabilir.
Yani işlemcinin verimliliği artar.
