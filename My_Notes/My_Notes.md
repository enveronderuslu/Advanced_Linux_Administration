**Linux System Basics** 
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
## Aliases & Bash Customization
Users have their own `.bashrc` file. To apply changes, `source ~/.bashrc`

Sample aliases :
```bash
alias sysupdate='dnf -y update'
alias c='clear' 
# en sonda  sIk kullanilanlara bak
```
Changing the System Hostname: `sudo hostnamectl set-hostname <NewName>`
Script Logging: `script deneme.txt # Type exit to stop`


alias yaz 3310 a gönder Sistemdeki alias lari listeler
cut -d : -f 3 /etc/passwd # 3. sütunu alir
bashrc icin ayri ayri ugrasma. /etc/bash.bashrc ye    yaz gitsin
ctrl e ile satir sonuna ctrl a ile satir basina gidersin.


### Usecae: Profil.d kulllanimi
Sistem genelinde tüm kullanıcılar için Vim’i varsayılan editör yapmak için:
sudo vi /etc/profile.d/editor.sh
Aşağıdaki satırları ekle:
#!/bin/bash
export EDITOR=$(which vim)
export VISUAL=$(which vim)
Dosyayı çalıştırılabilir yap:
sudo chmod +x /etc/profile.d/editor.sh
Bu ayar tüm kullanıcı oturumlarında otomatik yüklenir.
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
 - Kaynak Yönetimi: Sistem kaynaklarını (CPU, bellek ...) yönetitr. 
 - Günlükleme (Journaling): Sistem olaylarını ve servislerin çıktılarını merkezi bir yerde (journald) toplar. `journalctl`  komutu ile bu günlüklere erişilebilir.
 - Diğer Özellikler: Zamanlanmış görevler (systemd.timer ile cron yerine), ağ yapılandırması (systemd-networkd), kullanıcı oturum yönetimi (systemd-logind) gibi birçok ek özelliği de bünyesinde barındırır.
```bash
systemd-analyze + blame # makinenin baslamasi icin süre + detaylat 
/lib/systemd/system # services are here
```
## SYSTEMD (ADVANCED)
kisaca servis yönetimi (fazlasi var aslinda)

### Best Practices
Konfigürasyon Yönetimi
- Vendor dosyalarını değiştirme; /etc altında override kullan.
- Aynı serviste çok adım varsa ExecStart= yerine ayrı script kullan.

Bağımlılık ve Sıra Yönetimi
- Requires= servis gerekliliği, After= başlama sırası
- Gereksiz bağımlılıklardan kaçın, boot süresini kontrol et.

İzleme
- sytemctl status, journalctl -u ile sürekli servis durumu takibi.
- Timer tarafında Persistent= kullanarak kaçırılan zamanlamaları telafi et.

5) Güvenlik
- Servis çalıştırma ortamını mümkün olduğunca izole et:
- ProtectSystem=full, ProtectHome=yes, PrivateDevices=yes
- CapabilityBoundingSet= kullan
- Düzenli olarak servislerin override.conf yapılarını gözden getir.
- Güvenlik açısından tüm unit dosyalarında izolasyon ayarlarını standartlaştır.

Eğer yanlış bağımlılık kurarsan Sistem her boot sırasında o gereksiz servisi de bekler. Ve Boot süresi uzar. Servis zincirleme olarak gecikme yaratır.

Yanlış tasarım:
[Unit]
Requires=network-online.target
After=network-online.target

Doğru yaklaşım:
[Unit]
After=network.target

Yanlis tasaraim: Bir log toplama servisi:
Requires=mysql.service
After=mysql.service
Bu durumda Log servisi için MySQL’in önce açılması beklenir. MySQL geç açılırsa log servisi de bekler. Boot süresi gereksiz uzar. Doğrusu:
Wants=mysql.service
After=mysql.service
Bu durumda Bağımlılık zorunlu değildir; sistem gerekirse MySQL’i başlatmadan da boot eder.

Servis bağımlılıklarını düzenlerken “Requires” yerine mümkün olduğunca “Wants” tercih et.
## systemctl – Instruction Notes (Red Hat–based Systems)

sudo systemctl edit unit.type # Z.b. sshd.service
sudo systemctl edit # activate the changes 
sudo systemctl show sshd.service # servisle ilgili tüm detaylari görürsün
- socket: Socket unit (örnek: sshd.socket), bir servisin sadece ihtiyaç olduğunda çalışmasını sağlayan “tetikleme noktasıdır”. Bir servis direkt çalışmak yerine, sistem bir port veya dosya üzerinden istek alınca çalışır. 
sshd.socket # 22 numaralı portu dinler
sshd.service # Bir bağlantı olunca otomatik başlar

**Örnek**
[Unit]
Description=Basit Python HTTP Server

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
Bu dosya kaydedilip systemctl enable myhttp.service denildiğinde servis açılışta otomatik başlar.
Bu custom.target çağrıldığında myhttp.service ve nginx.service beraber yüklenir. Yani .service tekil yapı taşıdır, .target bunları organize eden şemsiye gibidir.
### Core Concepts
**Unit**: A configuration object managed by systemd (service, socket, mount, timer, target). Stored under `/usr/lib/systemd/system/` or `/etc/systemd/system/`.

**Target**: A unit type grouping other units to define a system state (e.g., `multi-user.target`, `graphical.target`, `rescue.target`). Replaces legacy runlevels.

---

### Commands

**systemctl start \<unit>**
Starts a unit immediately.  
**Best practice**: Start only validated, enabled services.  
**Use case**: Starting `httpd.service` after configuration.

**systemctl status \<unit>**
Shows active state, logs, metadata.  
**Best practice**: Always check status before troubleshooting.  
**Use case**: Verifying `sshd.service`.

**systemctl restart \<unit>**
Stops and starts the unit.  
**Best practice**: Use after config changes.  
**Use case**: Reloading web server settings.

**systemctl stop \<unit>**
Stops a running service.  
**Best practice**: Confirm no critical dependencies rely on it.  
**Use case**: Stopping `firewalld.service` safely.

**systemctl enable \<unit>**
Activates automatic start at boot.  
**Best practice**: Enable only essential long-running services.  
**Use case**: Enabling `chronyd.service`.

**systemctl disable \<unit>**
Prevents boot-time start.  
**Best practice**: Disable unused or risky services.  
**Use case**: Disabling an unused database service.

**systemctl list-units**
Shows loaded and active units.  
**Best practice**: Filter by type for clarity.  
**Use case**: Auditing running services.

**systemctl set-default \<target>**
Sets system boot target.  
**Best practice**: Use `multi-user.target` for servers.  
**Use case**: Switching from graphical to text-only mode.

**systemctl get-default**
Displays current default target.  
**Best practice**: Verify before rebooting.  
**Use case**: Checking that CLI mode is active.

**systemctl cat \<unit>**
Shows full unit definition.  
**Best practice**: Review before editing.  
**Use case**: Inspecting `sshd.service`.

**systemctl show \<unit>**
Displays all runtime properties.  
**Best practice**: Use for deep diagnostics.  
**Use case**: Verifying dependencies.

**systemctl edit \<unit>**
Creates drop-in overrides under `/etc/systemd/system/<unit>.d/`.  
**Best practice**: Never modify vendor files.  
**Use case**: Adding environment variables to a service.

**systemctl daemon-reload**
Reloads unit files after edits.  
**Best practice**: Run after any unit modification.  
**Use case**: Applying new service definitions.

**systemctl isolate \<target>**
Switches to another system state.  
**Best practice**: Use cautiously; may stop many services.  
**Use case**: Entering `rescue.target`.

**systemctl list-dependencies \<unit>**
Shows dependency tree.  
**Best practice**: Review before disabling or isolating.  
**Use case**: Understanding `graphical.target`.

**systemctl isolate emergency.target**
Enters minimal environment.  
**Best practice**: Use only for critical recovery.  
**Use case**: Fixing filesystem corruption.

**systemctl list-units -t target**
Lists all targets.  
**Best practice**: Identify available system states.  
**Use case**: Checking custom targets.

**systemctl edit sound.target**
Creates a drop-in for `sound.target`.  
**Best practice**: Adjust grouped services at the target level.  
**Use case**: Overriding audio subsystem behavior.

**systemctl start name.target**
Starts all units in the target.  
**Best practice**: Use for structured subsystem startup.  
**Use case**: Starting an application stack.

**systemctl isolate name.target**
Switches to the custom target.  
**Best practice**: Ensure all required core units exist.  
**Use case**: Application-specific environments.

**systemctl list-dependencies name.target**
Shows dependencies of a custom target.  
**Best practice**: Validate tree before production use.  
**Use case**: Checking completeness of grouped services.

**systemctl set-default name.target**
Sets a custom target as the boot default.  
**Best practice**: Apply only if thoroughly tested.  
**Use case**: Booting directly into an application environment.

**systemctl set-default emergency.target**
systemctl start default.target
Sets emergency mode as default, then returns to normal.  
**Best practice**: Avoid except in controlled recovery tests.  
**Use case**: Disaster-recovery validation.

**systemctl set-default graphical.target**
systemctl start default.target
Sets graphical mode as default and switches to it.  
**Best practice**: Use on workstations, not servers.  
**Use case**: Restoring GUI functionality.

## SYSTEMD CGROUPS
Ne işe yarar: 
1. Servislerin kaynak kullanımını sınırlar (CPU, RAM, I/O).
```Ini
mkdir -p /etc/systemd/system/httpd.service.d
cat > /etc/systemd/system/httpd.service.d/limits.conf 
[Service]
CPUQuota=40%
MemoryMax=800M
IOReadBandwidthMax=/ 10M
```

```bash
systemctl daemon-reload && systemctl restart httpd # Bu yapılandırma httpd servisine CPU, bellek ve I/O sınırı uygular. 
```

2. Servis seviyesinde izleme ve hata yönetimi yapılmasını sağlar.
```bash
systemctl status mariadb
systemd-cgtop # systemd-cgtop servisin CPU ve bellek kullanımını gerçek zamanlı gösterir.
```
3. Sistem kararlılığını artırır
```Ini
[Service]
MemoryMax=1G # Belirlenen sınır aşılırsa kernel OOM, yalnızca o servisi hedef alır.
```
4. Kaynak temelli performans teşhisi sağlar.
```bash 
systemd-cgls # Bu komut cgroup hiyerarşisini göstererek hangi servislerin hangi süreçlere sahip olduğunu, hangi grubun yük oluşturduğunu hızlıca ortaya çıkarır.
# Mesela
systemd-cgls | grep ssh
```

### .target .service dosyalari
`.service ` dosyaları bireysel servisleri tanımlar. `.target` dosyaları ise bu servisleri bir araya getirip topluca yönetir. `/lib/systemd/system/` veya `/etc/systemd/system/` icinde bulunurlar. 
`/usr/lib/systemd/` dizinindeki dosyalar sistemin varsayılan, paketle gelen systemd servis ve target tanımlarını içerir. Bu dosyalar güncellemelerle otomatik olarak değiştirilir.
`/etc/systemd/system/` dizini ise yönetici tarafından yapılan özelleştirmeler içindir. Buradaki dosyalar önceliklidir ve /usr/lib/systemd/ içindeki aynı isimli dosyaları geçersiz kılar.
Örnek: Varsayılan servis dosyası: /usr/lib/systemd/system/sshd.service
Özelleştirilmiş servis dosyası: /etc/systemd/system/sshd.service
Varsayılan dosyaları değiştirmek yerine `systemctl edit etwas.service` komutuyla override dosyası oluştur.

`.service` dosyası bir servisin kendisini tanımlar. İçinde hangi binary’nin çalıştırılacağı, hangi kullanıcıyla çalışacağı, ne zaman yeniden başlatılacağı gibi bilgiler olur. Örneğin: `myhttp.service` dosyasini olusturalim. 
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
custom.target, ağ servisleri (ör. IP yapılandırması, ağ arabirimlerinin aktif olması) hazır olmadan başlatılmaz. Bu, Requires= ile birlikte kullanıldığında, önce network.target başlar, sonra bu hedefteki servisler çalışır.
Bazi default .target dosyalari:
multi-user.target: ağ servisleri, çoklu kullanıcı, SSH, cron gibi servisleri çalıştırır. 
systemctl status multi-user.target
graphical.target GUI içeren sistemler için kullanılır. 
# Package Management with YUM and DNF
## Commands
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
A paketi B paketine bagli. B ist weg. A atil kaldi. A is a Orphan package
```py
dnf repoquery --unneeded
dnf remove $(dnf repoquery --unneeded -q)
```
Snap, Canonical (Ubuntu'nun geliştiricisi) tarafından geliştirilen bir paket sistemi. APPs kendi bağımlılıklarıyla paketlenir. `sudo snap install App1`

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
5. Dosyayi indirdigin yerde terminalde ` apt install ./sample.deb` yazsan direk calisacakti Aklini s*keyim
# User and Group Management
## Commands
```py
useradd # home directory veya psswrd olusturulmaz. Ek argümanlarla home directory olusturulur
adduser # home dir ve passwd olusturulur
adduser # güvenlik acisindan daha iyi
groupadd
userdel <user> # home directory silinmez
userdel -r <user> # home directory silinir
usermod -G <DROUP> <USER> # diger gruplardan cikarir. kendi ismindeki grup korumur
usermod -aG <GROUP> <USER> # diger gruplarda kalmaya devam eder
visudo /etc/sudoers # dosyasini acar 
who or users # makineyi o an kullanan kullanicilari verir
id Test_User # olusturdugun userin hangi gruplarda oldugunu görürsün
```
`etc/passwd` user accountlarla ilgili bilgiler
`etc/shadow` encrypted password ler burada.


passwd icinde degisiklik yapacaksan `vipw` kullan (Ayni `visudo` da oldugu gibi) Yaptigin degisiklikleri kontrol eder ve hata varsa uyari verir- group lar icin `vigr`
/etc/login.defs icinde degisiklikler yaparak yeni olusturulacak user larin özellikleri ayarlanabilir. 

/etc/skel dizini, yeni kullanıcı oluşturulduğunda onun ana dizinine (home directory) otomatik kopyalanacak varsayılan dosyaları içerir.
## Password Policies
`chage -l # current settings`
sudo chage <USER_NAME> adim adim ayarlamalari yaparsin
PASSWORD AGING: `chage -m mindays -M maxdays -d lastday`
`sudo nano /etc/login.defs` dosyasinda bu sayilari düzelt. Bu yeni sistemlerde artik yok. Peki ne var: ` /etc/security/pwquality.conf` yine FAILED LOGINLER ICIN `/etc/security/faillock.conf` 
## Session Management
loginctl en yeni arac. `w` veya `who` komutlarida olur. 
loginctl list-sessions # tüm sessions ve session number
loginctl show-session <session_number> # detayli bilgi
loginctl terminate-session <session_number>

### Using `ps`

`ps aux | grep  ssh` bununla tüm ssh processlerini ve PID lerini görürsün

ctrl + z islmei arkaya atar. jobs ile bu islemleri görürsün. %1 sana arkada calisan 1 numarali processi getirir. fg veya bg foreground background

ps auxZ | grep -E 'httpd|COMMAND' # 'httpd|COMMAND' ifadesi, hem httpd içeren satırları hem de başlık satırını (COMMAND) filtreler. Böylece çıktıda işlemler ve sütun başlıkları birlikte görünür.


### SYSTEM MONITORING
`top -u user1` user1 ne kullaniyor sadece bunu gösterir
top 

| Kolon     | Açılım               | Açıklama  |
| --------- | -------------------- | ------------------ |
| `PID`     | Process ID           | İşlem kimliği |
| `USER`    | User                 | İşlemi başlatan user |
| `PR`      | Priority             | İşlem önceliği |
| `NI`      | Nice value           | Nice islem önceliğini belirler |
| `VIRT`    | Virtual Memory       | Sanal bellek kullanımı (MB/KB) |
| `RES`     | Resident Memory      | Fiziksel RAM kullanımı   |
| `SHR`     | Shared Memory        | Paylaşılan bellek miktarı  |
| `S`       | State                | İşlem S: uyku, R: çalışıyor, Z: zombie |
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
ps fax # parent child processes
top komutu ps den daha iyi
kill basiert auf PID
killall basiert auf Processname 

w shows all current sesions
```bash 
pgrep -l -u bob # bob isimli user la ilgili processes
```

```py
pkill -SIGKILL -u <user> # user ile ilgili tüm prosesleri kill yapar
```

```py
pstree -p newuser # proses agaci
```

###  `nice`, `renice`

`nice` : scheduling priority. -20 = en yüksek öncelik. negatif degeri sadece adminler verebilir. 19 = en düşük öncelik (sisteme en az yük olur). 
`renice` komutuyla siralamayi degistirirsin
## Scheduled Tasks

systemd timer en modern olani. Crontab eski sürümlerde var
sudo systemctl list-unit-files  -t  timer # systemd timer  Scheduled task lari verir 
sudo systemctl list-unit-files  backup* # ismi backup ile baslayan dosyalari yakalarsin
sudo systemctl  cat backup-sysconfig.timer # icerigi yakalar
The ` wall ` command in Linux is a powerful tool that allows users to send messages to all logged-in users' terminals. 
### Örnek

- Schedule a tasks that writes the text "good morning" to the default system logging system every day at 5 AM
Create the file /etc/systemd/system/goodmorning.service:

```bash
[Unit]
Description=Daily Good Morning Log Message
[Service]
Type=oneshot
User=bob # Ensure this task runs as user bob
ExecStart=/usr/bin/logger "good morning"
```
Unit:  Contains general information.
Service: Defines the task.
Type=oneshot: Specifies the service runs the command and then exits.
ExecStart: The command to run.

Create the file /etc/systemd/system/goodmorning.timer:

```bash 
[Unit]
Description=Run goodmorning.service every day at 5 AM
[Timer]
OnCalendar=*-*-* 05:00:00
Unit=goodmorning.service
[Install]
WantedBy=timers.target
```

OnCalendar=*-*-* 05:00:00: It means:
*: Any day of the week.
*-*-*: Any year, month, or day of the month.
05:00:00: Exactly 5 AM .
Unit=goodmorning.service: Specifies which service unit to activate when the timer expires.
Install: Specifies that the timer should be active for the timers.target.

```bash
sudo systemctl daemon-reload
sudo systemctl enable goodmorning.timer
sudo systemctl start goodmorning.timer
systemctl status goodmorning.timer # Verify the Timer
```
eski usül;
log in as bob and then run `crontab -e` and write `0 5 * * * /usr/bin/logger "good morning"`. Veya `sudo nano /etc/crontab` icinde degistir

# Networking
## netstat -tunp

|         Alan     |               Açıklama                  |
| ---------------- | ----------------------------------------|
| Proto            | Protokol türü: TCP, UDP, RAW gibi.      |
| Recv-Q / Send-Q  | Alınan ve gönderilen veri kuyrukları.   |
| Foreign Address  | Bağlı olan uzak IP ve port.             |
| PID/Program name | Bağlantıyı kullanan işlem adı ve PID    |


| Durum               | Ne Anlama Gelir?             |
| ------------------- | ---------------------------- |
| LISTEN              | Port dinlemede. |
| ESTABLISHED         | Aktif bir bağlantı var |
| CLOSE\_WAIT         | Karşı taraf kapattı ama sizin taraf hala kapatmadı |
| TIME\_WAIT          | Bağlantı kapatıldı ama bir süre daha beklemede |
| SYN\_SENT SYN\_RECV | TCP bağlantısı kurulmaya çalışılıyor.  |
## NETWORK ADVANVECD 
ip link # shows network interfaces
sudo lshw -class network # deeper information
man nmcli-examples # yapabileceklerinle ilgili örnekler. Z.b.
nmcli device wifi list
/etc/hosts   # hier stehen die Hostnamen

`/etc/nsswitch.conf`, isim çözümleme ve kimlik doğrulama işlemlerinde hangi kaynağın hangi sırayla kullanılacağını belirleyen yapılandırma dosyasıdır.
örnegin passwd: files ldap  Kimlik bilgileri önce yerel dosyalardan, sonra LDAP’tan alınır.



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

dig @4.2.2.2 google.com -> google.com alan adının IP adresini, 4.2.2.2 DNS sunucusunu kullanarak sorgular.
/etc/resolv.conf 

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

nmcli; temiz network device adress bilgisi veriyor
nmcli device show
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
## Firewall Configuration with `firewalld`
fedore ve RHEL de firewall dan port acma 
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
# Storage and Disk Management
## 
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
## ADVANCED RESOURCING
/usr/etc/security/limits.conf # config file
ulimit -a # OLD SCHOOL all limitations in the system
SysRq (Magic SysRq Key), SysRq, çekirdek seviyesinde debugging, süreç sonlandırma, senkronizasyon ve güvenli reboot gibi işlemleri gerçekleştiren bir kurtarma arabirimidir.
Örnek. Alt + SysRq + REISUB; Kilitlenmiş sistemi güvenli şekilde yeniden başlatmak için kullanılan sıralı komut seti. Sol el ile Alt tuşuna, Sağ el ile PrintScreen/SysRq tuşuna basılı tut. SysRq tuşunu bırakmadan REISUB harflerine sirayla bas. 
# Security
## FIREWALLING
firewall-cmd --list-services # list, get, set, list, remove bunlari  --help icinde ara
firewall-cmd --runtime-to-permanent # firewall calisirken yaptigin degisiklikleri kalici yapar

### Rich Language
The rich language extends the current zone elements (service, port, icmp-block, icmp-type, masquerade, forward-port and source-port) with additional source and destination addresses, logging, actions and limits for logs and actions.
man 5 firewalld.richlanguage # en sonda örnekler var
## LINUX OS HARDENING

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
 Security Enhanced linux 
 /etc/sysconfig/selinux burada detaylar var
- Change listening Services Port numbers

head etwas.txt shows first 10 line of the file
tail etwas.txt shows last 10 line of the file
tail -n 20 etwas.txt
sudo tail -f  /var/log/syslog eklendikce yenileri  görürsün

```bash
 mkdir $(cat folder.txt) 
 cat folder.txt | xargs mkdir # xargs, komut satırında bir veriyi alır, komutlara argüman olarak dönüştürür
```
## `GREP` ve `FIND`

```bash
find  / -name *.doc 2> /dev/null
sudo updatedb && locate deneme.txt # daha hizli bulur
grep -c -i Ali names.txt # Dosyada ali isminin kac kere gectigini -c , büyük Kücük harf hassasiyetrinden kurtulmayi -i sagllar. 

grep -r # search in subdirectories
grep -ri ebenin* # recursively tüm dosya isimleri ve iceriklerinde ebenin kelimesiyle baslayan kelemeleri bulur

whereis # tüm hardawre da aramaz path de arar 
which  # in farki direk command in nerede calistigini verir
find / -name *.pdf 2> /dev/null
find / -size +100M 2> /dev/null
find / -perm /g=w,o=w 2> /dev/null # w Hakki olan gruplar ve other people bulunur
find  -perm /4000
locate # hizli  updatedb
```

sudo chown cemsit deneme.txt dosyanin owner ini cemsit yapar
sudo chown -R cemsit Folder_Name # hem klasorun Hemde altinda ne varsa hepinin sahabini degistirdi
sudo chown -R  cemsit:cemsit klasor/ hem kullanici hem grup degisti
# Filesystem Management
## Special Permissions

`setuid (setguid)`: Dosya; sahibinin (grup) yetkileriyle çalışır `chmod u+s veya (g+s) <dosya>` 
`setgid` : Klasör; Klasöre eklenen dosyalar aynı grup ile `chmod g+s <klasör>`
`sticky` : Klasör; Klasördeki dosyalar, sadece sahibi veya root tarafından silinebilir `chmod +t klasör`  

setuid/setgid sadece “komut gibi çalıştırılabilen” dosyalarda anlamlıdır. Metin dosyası yada veri dosyasında etkisi olmaz. kabaca bil yeter. Bugünlerde setfacl kullanilir.
## `setfacl` ve  `getfacl` 
setfacl -m u:cemsit:rw deneme.txt enver kullanicisinin üzerinde 
Hakki olan deneme.txt dosyasina cemsit isimli user atandi (gruba hak taniyacaksan u yerine g yaz)
gertfacl deneme.txt ile detaylari görürsün.

directory icinde setfacl uygulanir fakat inherited olmasi icin :

sudo setfacl -m u:user1:rw reports/ bununla reports dosyasininicindekilere inherit edemezsin. 
sudo setfacl  -d -R -m  u:user1:rw reports/ yaparsan asagi Dogru gider
setfacl -m u:test:--x /root # biseyi calistirma || root listeleme hakki vermez. Sadece gecis yapmayi saglar. baska türlü dosyaya atlayamaz
setfacl -m u:test:r /root/deneme.txt 

chattr +i dosya.txt # Dosya değiştirilemez
chattr +a log.txt # Dosyaya sadece ekleme yapılabilir.

umax file olusturulunca otomatik verilecek yetkileri belirler

cat /etc/fstab  file system table


ls .. what is in the parent dirctory
ls -d D* bulundugun yerde D ile baslayan directories
ls -d test_directory test kalsörüyle ilgili özellikler
tree <Directory_Name>
ln mainfile.txt  sonradanolusanfile.txt  link yapma  herhangibirinde yaptigin degisiklik digerinde de olusur

file creation default icin umask degeri kullanilir. Mesela 022 aslinda 755 tir. umask degeri 777 den cikarilir umask /etc/bashrc icinde bu degeri degistirebilirsun

sudo du -h --max-depth=1 /  2>/dev/null  root tan itibren bir dosya aagiya Kadar ne varsa onlaeri ve diskusage leri bulur

### Hard- Softlink

ln test linktest # test dosyasina hardlink  yaptik. Birini silsen digeri  calismaya devam eder
ls -li # inode numarasini verir
ln -s test symlintest # sembolik link olusturur
ikinci satirtdaki "2" sayisi ayni inode numarasina sahip dosya sayisini gösterir

link olusturma ln -s testdir/file1.txt link1
rm -rf öpcelenmeden herseyi siler 
tail -n 1 /etc/group veya /etc/passwd 

### `getenforce`, `setenforce`
### `semanage`, `restorecon`, `getsebool`
# System Monitoring and Performance
## I/O Monitoring
### Monitoring Tools 

ps fax # parent child processes
top komutu ps den daha iyi
kill basiert auf PID
killall basiert auf Processname 


- `htop`  # A better, interactive version of `top` with a cleaner UI
- `top` → press `Enter`, then `Shift + M`  
  Sorts processes by memory usage
- `vmstat`  # Reports current memory and system activity
- `iotop`  # Displays real-time disk read/write by processes
- `nmon`  # Powerful monitoring tool for all system statistics
iotop kullanilabilir. dnf  install iotop ile kurmalisin. 
### dd KOMUTU
dd if=ornek.iso of=/tmp/kopya.iso bs=1M # Bir dosyayı kopyalama. bs (block size), dd’nin her okuyup yazdığı veri parçasının büyüklüğüdür. 1M, 1 megabaytlık bloklarla okuma/yazma yapılacağı anlamına gelir.
dd if=/dev/sda of=/tmp/disk.img bs=4M # Bir disk imajı oluşturma
dd if=ornek.img of=/dev/sdb bs=4M status=progress # Bir imajı diske yazma. status=progress kopyalanan veri miktarını ve hızını terminalde canlı olarak gösterir.
## KERNEL & KERNEL MODULES
`findmnt` shows the mounted  devices
`sudo umount /dev/sr0` ile istedigin cihazi unmoint edersin
options → bağlama seçenekleri, virgülle ayrılır: 
- defaults → varsayılan seçenekler
- noauto → otomatik bağlama yok
- ro → salt okunur
- rw → okunabilir ve yazılabilir

kernel tuning: çekirdek seviyesinde performans, güvenlik veya kaynak kullanımını optimize etmek için yapılan ayarlamalardır.

### Kernel Tuning
/proc sistem durumu ve kernel parametrelerini izlemek ve değiştirmek için kullanılan sanal bir arayüzdür erçek disk üzerinde fiziksel olarak var olmaz. Amaç: çekirdek ve sistem bilgilerini kullanıcıya sunmak.
- Dosyalar fiziksel değil, RAM üzerinden çekirdek tarafından oluşturulur.
- Bazı dosyalar sadece okunur, bazıları ise kernel parametrelerini değiştirmek için yazılabilir.
- Dinamik içerik. Sistem çalıştıkça içerik güncellenir.

Örnek Dosyalar ve Klasörler
- /proc/cpuinfo İşlemci bilgileri (model, çekirdek sayısı, hız)
- /proc/meminfo Bellek durumu (toplam, boş, swap)
- /proc/uptime  Sistem çalışmaya başladığından beri geçen süre

`/sys` provide info about devices and their attributes. Donanim ve sürücüler hakkinda bilgi verir. 

`/proc/sys` Kernelin tuning ve runtime yapılandırma parametrelerini sunar.
sysctl komutunun doğrudan arayüzüdür.

`/sys` (sysfs): Kernel içindeki donanım, sürücü ve çekirdek nesnelerini hiyerarşik şekilde gösterir. Gerçek zamanlı donanım durum bilgisi sağlar.

## BOOT OPERATIONS
### Emergency Mode
- Reboot your system.
- Interrupt the boot loader countdown (by pressing a key like "e" ).
- Locate the kernel command line (often starts with linux or linux16).
- Append systemd.unit=emergency.target to the end of that line.
- Boot using Ctrl+x or F10, depending on the bootloader instructions). 
## Reading Logs with `journalctl`
## Syslog vs. Rsyslog
Syslog is the basic protocol and original daemon, while Rsyslog is an advanced version with many more features. Rsyslog is modern and default for many Linux distributions. 
# Troubleshooting and Recovery
##  What Is Troubleshooting in Linux?

Troubleshooting means:
- Detecting what’s wrong
- Diagnosing the cause
- Applying a fix
- Testing if the fix worked

Recovery is what you do **after something breaks** — like when your system doesn’t boot, or a service crashes.

### LOG MONITORING 
Log directory /var/log/secure   all login logout activities
tail -f secure dinamik olarrak log penceresi acik kalir 

httpd apache application log 
## LINUX LOGGING
journalctl -u cron.service # cron servisi (unit i ile ilgili) loglari gösterir.
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

load avarage: uptime veya cat /proc/loadavg ile bulunur. son 1, 5 ve 15 dakikalik load avarage (cpu) kullanimini verir. lscpu da degerleri verir 


### Example: A Service Isn’t Starting

Your Apache web server isn’t starting. Step-by-step:

```bash
systemctl status httpd  # Check service status
journalctl -xeu httpd # View logs
# Look for errors** like:
"Permission denied"
"Port already in use"
"SELinux denial"
apachectl configtest  # Check configuration syntax
systemctl restart httpd # Fix the issue and restart
```

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

### System Running Slow?
```bash
top # CPU Usage
free -m # Memory Usage
df -h # Disk Space
iostat # I/O Wait
ps aux | grep 'Z'  #Zombie Processes
```
### Application Crashes

When an app crashes:

- Use `journalctl` to see logs
- Use `strace` to trace it: `strace ./appname`
- Look at core dumps: ` coredumpctl list &&  coredumpctl info <PID>`

DNS problems: Server is not reaxhable
```bash 
 cat /etc/hosts
 cat /etc/resolv.conf
 cat /etc/nsswitch.conf
 ping gateway
```

WEBsite or Application is not erreichbar
ping with ip adress or hostname
telnet 192.168.178.x 80 port calisip calismadigini gösterir
/etc/ssh/ssh_config  ssh ile giderken yapilan ayarlar 
/etc/ssh/sshd_config gelen ssh baglantilaei icin ayarlar
/var/log/secure  burayi tail -f ile izlersen  canli tüm loginleri görürsün
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

pwconv, şifreleri güvenli bir şekilde saklamak için kullanılır. Şifreler /etc/passwd içindeyse, bu komut onları /etc/shadow'a taşır ve /etc/passwd içindeki şifre alanını x olarak değiştirir.

LAST komutu sisteme login olanlari bulur 

Rollback Update Nedir? Rollback update, bir sistem veya yazılım güncellemesi yapıldıktan sonra, eski (önceki) sürüme geri dönme işlemidir.

sos report komutu  rhel ve rocky linux sistemlerde;
Sistem hakkında ayrıntılı teşhis bilgileri toplar:
Donanım bilgileri
Ağ ayarları
Servis durumları
Log dosyaları
Yüklü paketler
Çekirdek bilgileri vs. 



VIM Kullanimi
yy satir yw kelime kopyalar p yapistirir
dd / de satir / üzerinde oldugu kelimeyi  siler 
/word yazarsan dosya icindeki ilk "word" kelimesini bulur. Sonra n harfine basarak
sirasiyla digerlerini bulursun. 
asagidan yukari arama: shift + g ile dosyanin sonnuna git. 
Satir numaralarin inasil gösterirsin: escape modda:set number
3 shift g  ile 3. satira gidersin
kelime degistirme: kelimenin üstüne gel cw yaz sonra yeni kelimeyi yaz
## System Architecture and BOOT Process
## Command Cheat Sheet
date  uptime(1, 5, 15 dakikalarda cpu kullanimi)   
hostname   uname   ehich  
cal 11 1976
bc calculator
`cp  -pr`  klasörü icindekilerle  kopyalaar
`cat  -n`  satirlari numaralandirarak cikti verir
`cat isimler.txt| sort`    satirlari bas harflerine göre siralar
&& önce sol taraf  sonra sol calisirsa sag taraf calisir
echo -e icerdeki özel karakterleri algila
Bash script te cift tirnak kullan
tmux (Terminal Multplex Command) terminal ekranini birkac bölmeye ayirir
bin & sbin :  executables for all & executanles for root  
Bir script calisacaksa nerelerde aranir 
PATH=/root/... Mesela deneme.sh dosyasini bu dizinlerden birine tasi Sonra istedigin yerde direk calistir 
export PATH=$PATH:/home/rocky2/Skripten (Yeni path olusturacaz. Mevcut path i $PATH ile ekledik )

Thread (İş Parçacığı): Çekirdeklerin aynı anda birden fazla işi işleyebilmesini sağlayan mantıksal işlem yolları. Yani işlemcinin verimliliği artar.

&&  baglacida ; gibi kullanilabilir fakat komut1 && komut2 farkli anlama gelir. birinci calisr ise ikinci calisir. ; de birbirinden bagimsiz calisir.
benzer sekilde komut_1 || komut_2 var. Bu defa sol taraf hata dönerde sag taraf  calisir-  sol taraf calisirsa sag calismaz. XOR gibi 

yine `<command> &` ile komut arka planda calisir. 
# HARiCi
## BASlarken (SIK kullanilanlar)

```bash
git config --global user.email  "enveronderuslu@gmail.com"  &&  git config --global user.name "Enver Onder Uslu"

ssh-keygen -t  rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub remote@192.remote_IP 
 
sudo dpkg-reconfigure console-setup  #ubuntu serverda font VGA 16:32 yap cicek 

```

```bash
Local to Remote:
scp -r /path/to/local_folder username@remote_host:/path/to/destination
Remote to Local:
scp -r username@remote_host:/path/to/remote_folder /path/to/local_destination
```



```bash
alias sysupdate='sudo zypper dup'
alias z='zypper'
alias c='clear'
alias l='ls -laFtr  --color=auto'
alias ping='ping -c 5'
alias ports='ss -tulanp' 
alias shut='sudo shutdown now'
PS1='$ ' # ekranda sadec $ isareti olsun istediginde
```
```bash
sudo usermod -l  fedora1 fedora && sudo usermod -d /home/fedora1 -m fedora1 # user ismi ve homedirectory degistir
```

```bash
# gerekirse virtualbox ta sanallara ssh baglantisi icin  port forwarding yaptiktan sonra 
alias debian1=' ssh  -p 2221 debian1@127.0.0.1'
# yine gerekirse anahtar tasima icin
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2231 fedora1@127.0.0.1
```
### sudo derdinden kurtulmak istiyorum: 
Hedef makinada sunu ekle:
```bash
sudo visudo
boss ALL=(ALL) NOPASSWD: ALL
# Eğer sadece reboot komutu için yetki vermek istersen:
test ALL=(ALL) NOPASSWD: /sbin/reboot
```
## D-Bus busctl list
D-Bus (Desktop Bus), Farklı uygulamaların birbirleriyle veri veya komut paylaşmasını sağlar. Merkezi bir iletişim kanalı sağlar. Örneğin, bir uygulama diğerine “bu dosya açıldı” mesajı gönderebilir.
Bir daemon (genellikle dbus-daemon) sürekli çalışır ve mesajları gönderip alır. Tipik Kullanım: Masaüstü ortamları (GNOME, KDE) ve sistem servisleri arasında iletişim.
## Runtime configuration 
Runtime configuration; uygulamanın davranışını kod değiştirmeden ve yeniden derlemeden yönetmeye yarar. Z.b. bir web sunucusunun port numarasını veya log seviyesini bir config.yaml dosyasından uygulama her başlatıldığında okuması. Uygulama çalışırken dosya değişirse ve sunucu bu değişikliği yeniden yükleyebiliyorsa, bu bir runtime configuration kullanım örneğidir. 
## Application (service), Process, Daemon
Application=Service: Script list of instructions. 
Process: when you start a service(app) it starts a Process and process id
Daemon: etwas continuously runs in background. It is also a process
## Sourcing vs. Running a Script
Terminalde  `VAR=1` seklinde bir degisken tanimla.
sonra  asagidaki Scripti yaz

#!/bin/bash
echo $VAR   # boş, değişken görünmez
`./script.sh` dersen mevcut shell den bagimsiz calisir ve cikti vermerz. 
`source script.sh` yaparsan 1, değişkeni mevcut shell’de görünüyor