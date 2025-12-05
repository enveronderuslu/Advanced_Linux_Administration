```bash
git config --global user.email "enveronderuslu@gmail.com" &&
git config --global user.name "Enver Onder Uslu"
 
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub target_user@target-IP
```
 
```bash
alias sysupdate='dnf -y update'
alias c='clear'
alias l='ls -laFtr  --color=no'
alias ping='ping -c 5'
alias ports='ss -tulanp'
PS1='$ '
```

```bash
systemd-analyze + blame # makinenin baslamasi icin süre + detaylat 
/usr/lib/systemd/system # services are here
```

```bash
ls -d D* bulundugun yerde D ile baslayan directories
ls -d test_directory test kalsörüyle ilgili özellikler
tree <Directory_Name>
ln test linktest # test dosyasina hardlink  yaptik. Birini silsen digeri  calismaya devam eder
ls -li # inode numarasini verir
ln -s test symlintest # sembolik link olusturur
```
inode dosyaya ait meta data (izinler, tarihler usw.) tutar. Dosya ismi degilde bir numara tutar. farkli isimler ayni numaraya atanabilir. Böylece hardlinkler  olusturulur. Yani iki farkli isim ayni dosyaya isaret edebilir. Symlink ise bir hard link icin shortcut tir.  

```bash
ls -li test 
258147 -rw-rw-r-- 2 ubuntu ubuntu 35 Nov  1 16:04 test
```
ikinci satirtdaki "2" sayisi ayni inode numarasina sahip dosya sayisini gösterir

find  -perm /4000
find yavas  locate hizli  updatedb
which exact location of binary files
alias yaz 3310 a gönder Sistemdeki alias lari listeler
cut -d : -f 3 /etc/passwd # 3. sütunu alir
bashrc icin ayri ayri ugrasma. /etc/bash.bashrc ye    yaz gitsin
ctrl e ile satir sonuna ctrl a ile satir basina gidersin. 

passwd icinde degisiklik yapacaksan `vipw` kullan (Ayni `visudo` da oldugu gibi) Yaptigin degisiklikleri kontrol eder ve hata varsa uyari verir- group lar icin `vigr`
/etc/login.defs icinde degisiklikler yaparak yeni olusturulacak user larin özellikleri ayarlanabilir. 

```bash
id Test_User # olusturdugun userin hangi gruplarda oldugunu görürsün 
```

/etc/skel dizini, yeni kullanıcı oluşturulduğunda onun ana dizinine (home directory) otomatik kopyalanacak varsayılan dosyaları içerir.

### Usecae: Profil.d kulllanimi
Sistem genelinde tüm kullanıcılar için Vim’i varsayılan editör yapmak için:
```bash
sudo vi /etc/profile.d/editor.sh
```
Aşağıdaki satırları ekle:
```bash
#!/bin/bash
export EDITOR=$(which vim)
export VISUAL=$(which vim)
```
Dosyayı çalıştırılabilir yap:
```bash
sudo chmod +x /etc/profile.d/editor.sh
```

Bu ayar tüm kullanıcı oturumlarında otomatik yüklenir.

### .target .service dosyalari
.service dosyası bir servisin kendisini tanımlar. İçinde hangi binary’nin çalıştırılacağı, hangi kullanıcıyla çalışacağı, ne zaman yeniden başlatılacağı gibi bilgiler olur. Örneğin:
```ini
[Unit]
Description=Basit Python HTTP Server

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
```

Bu dosya kaydedilip systemctl enable myhttp.service denildiğinde servis açılışta otomatik başlar.

.target dosyası ise doğrudan bir servis tanımlamaz; sadece bir grup mantıksal hedef sunar. Örneğin:
```ini
[Unit]
Description=Custom Services Target
Requires=myhttp.service
Requires=nginx.service
After=network.target
```

Bu custom.target çağrıldığında myhttp.service ve nginx.service beraber yüklenir. Yani .service tekil yapı taşıdır, .target bunları organize eden şemsiye gibidir.

w shows all current sesions
```bash 
pgrep -l -u bob # bob isimli user la ilgili processes
``` 
Application=Service: Script list of instructions. 
Process: when you start a service(app) it starts a Process and process id
Daemon: etwas continuously runs in background doesnt stops. it is also a process


fedore ve RHEL de firewall dan port acma 
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

how to copy a file from a server to another? scp test.txt  kali@192.168.178.114:/home/kali/Desktop
timedatectl set-timezone Europe/Berlin

a faster and more modern replacement for netstat.
```bash
ss -tuln         # Show listening TCP/UDP ports with numeric addresses
ss -s            # Display summary statistics
ss -plnt         # Show listening TCP sockets with process info
```
grep -ri ebenin* # recursively tüm dosya isimleri ve iceriklerinde ebenin kelimesiyle baslayan kelemeleri bulur
find / -perm /g=w,o=w 2> /dev/null # w Hakki olan gruplar ve other people bulunur
sudo chown -R  cemsit:cemsit Folder/ # hem kullanici hem grup degisti 

setfacl -m u:cemsit:rw deneme.txt enver kullanicisinin üzerinde Hakki olan deneme.txt dosyasina bir user atadim (gruba hak taniyacaksan u yerine g yaz) parent klasörlere hak vermezsen en altta izin aldigin dosyaya ulasamazsin. Her kapi icin ayri izin lazim. 
```bash
getfacl deneme.txt # ile detaylari görürsün.
sudo setfacl -m u:user1:rw reports/ # reports dosyasinin icine inherit edemezsin.
sudo setfacl  -d -R -m  u:user1:rw reports/ # yaparsan asagi dogru gider
```

ls .. what is in the parent dirctory
ln mainfile.txt  sonradanolusanfile.txt  link yapma  herhangibirinde yaptigin ddegisiklik digerinde de olusur. `find` komutu cok masraflidir bunnun yerine locate daha iyi. 

Log directory /var/log/secure   all login logout activities

Your Apache web server isn’t starting. Step-by-step:

```bash
systemctl status httpd  # Check service status
journalctl -xeu httpd # View logs
# Look for errors like
"Permission denied" && "Port already in use" && "SELinux denial"
apachectl configtest  # Check configuration syntax
systemctl restart httpd # Fix the issue and restart
```
System Running Slow?
```bash
top # CPU Usage
free -m # Memory Usage
df -h # Disk Space
iostat # I/O Wait
ps aux | grep 'Z'  #Zombie Processes
ps fax # üarent child processes
```
top komutu ps den daha iyi
kill basiert auf PID
killall basiert auf Processname 

## Scheduled Tasks 
systemd timer en modern olani. Crontab eski sürümlerde var

```bash
sudo systemctl list-unit-files  -t  timer # systemd timer  Scheduled task lari verir 
sudo systemctl list-unit-files  backup* # ismi backup ile baslayan dosyalari yakalarsin
sudo systemctl  cat backup-sysconfig.timer # icerigi yakalar
```
The ` wall ` command in Linux is a powerful tool that allows users to send messages to all logged-in users' terminals. 

## Syslog vs. Rsyslog
Syslog is the basic protocol and original daemon, while Rsyslog is an advanced version with many more features. Rsyslog is modern and default for many Linux distributions. 

## Sourcing vs. Running a Script
Terminalde  `VAR=1` seklinde bir degisken tanimla.
sonra  asagidaki Scripti yaz

```bash
#!/bin/bash
echo $VAR   # boş, değişken görünmez
```
`./script.sh` dersen mevcut shell den bagimsiz calisir ve cikti vermerz. 
`source script.sh` yaparsan 1, değişkeni mevcut shell’de görünüyor

## KERNEL & KERNEL MODULES
`findmnt` shows the mounted  devices
`/etc/fstab` (file system table) dosyası, Linux’ta sistem açılırken hangi dosya sistemlerinin ve cihazların nereye ve nasıl bağlanacağını (mount) belirten yapılandırma dosyasıdır.
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
- /proc/cpuinfo	İşlemci bilgileri (model, çekirdek sayısı, hız)
- /proc/meminfo	Bellek durumu (toplam, boş, swap)
- /proc/uptime	Sistem çalışmaya başladığından beri geçen süre

`lsblk` List information about block devices. Özellikle sda lar. 
`/sys` provide info about devices and their attributes. Donanim ve sürücüler hakkinda bilgi verir. 

`/proc/sys` Kernelin tuning ve runtime yapılandırma parametrelerini sunar.
sysctl komutunun doğrudan arayüzüdür.

`/sys` (sysfs): Kernel içindeki donanım, sürücü ve çekirdek nesnelerini hiyerarşik şekilde gösterir. Gerçek zamanlı donanım durum bilgisi sağlar.

## SYSTEMD (ADVANCED) 
Systemd, servislerin, boot sürecinin ve sistem bileşenlerinin yönetilmesini sağlayan init sistemidir. Vazifesi sistem açılırken ve çalışırken tüm servisleri başlatmak, durdurmak, izlemek ve düzenlemektir.
Servis akışını anlamak için `systemctl list-units` çıktısını incele.

Systemd unit, systemd tarafından yönetilen servis, hedef, mount, socket ve benzeri bileşenleri tanımlayan yapılandırma dosyasıdır. Her unit, sistemde bir işlevin nasıl başlatılacağını, durdurulacağını, izleneceğini ve bağımlılıklarının nasıl ele alınacağını belirtir.
```bash
sudo systemctl edit unit.type # Z.b. sshd.service
sudo systemctl edit # activate the changes 
sudo systemctl show sshd.service # servisle ilgili tüm detaylari görürsün
```
- Servislerin (daemons) yönetimi
- Boot sırasının düzenlenmesi
- Kaynak bağımlılıklarının tanımlanması
- Otomasyon ve izleme

En Önemli Unit Türleri

- service: En yaygın tür. Arka plan servisleri.
- socket: Socket unit (örnek: sshd.socket), bir servisin sadece ihtiyaç olduğunda çalışmasını sağlayan “tetikleme noktasıdır”. Bir servis direkt çalışmak yerine, sistem bir port veya dosya üzerinden istek alınca çalışır. 

```bash
sshd.socket # 22 numaralı portu dinler
sshd.service # Bir bağlantı olunca otomatik başlar
```
- target: Boot aşamalarını gruplayan mantıksal birimler.
- mount / automount: Dosya sistemleri montajı.
- timer: Cron alternatifi zamanlayıcılar.

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

Systemd servisleri arasında bağımlılık (dependency) tanımları vardır.
Örnek parametreler:
- Requires= , Wants= , After= , Before=
Eğer yanlış bağımlılık kurarsan Sistem her boot sırasında o gereksiz servisi de bekler. Ve Boot süresi uzar. Servis zincirleme olarak gecikme yaratır.

Yanlış tasarım:
```bash
[Unit]
Requires=network-online.target
After=network-online.target
```
Eğer servis aslında ağ gerektirmiyorsa Sistem, network-online.target tamamlanana kadar o servisi başlatmaz.Boot süresi gereksiz yere uzayabilir.

Doğru yaklaşım:
```bash
[Unit]
After=network.target
```
Yani servis ağ bağlantısı “olmadan” da başlayabiliyorsa Requires kullanılmamalıdır.

Yanlis tasaraim: Bir log toplama servisi:
```bash
Requires=mysql.service
After=mysql.service
```
Bu durumda Log servisi için MySQL’in önce açılması beklenir. MySQL geç açılırsa log servisi de bekler. Boot süresi gereksiz uzar. Doğrusu:
```bash
Wants=mysql.service
After=mysql.service
```
Bu durumda Bağımlılık zorunlu değildir; sistem gerekirse MySQL’i başlatmadan da boot eder.

Servis bağımlılıklarını düzenlerken “Requires” yerine mümkün olduğunca “Wants” tercih et.

## SYSTEMD CGROUPS
Linux sistemlerde systemd cgroups (control groups), işlemlerin CPU, bellek, I/O gibi kaynak kullanımını sınıflandırmak, izlemek ve sınırlandırmak için kullanılan çekirdek mekanizmasının systemd tarafından yönetilen halidir.

Ne işe yarar: 
1. Servislerin kaynak kullanımını sınırlar (CPU, RAM, I/O).
```bash
mkdir -p /etc/systemd/system/httpd.service.d
cat > /etc/systemd/system/httpd.service.d/limits.conf 
[Service]
CPUQuota=40%
MemoryMax=800M
IOReadBandwidthMax=/ 10M
systemctl daemon-reload && systemctl restart httpd
# Bu yapılandırma httpd servisine CPU, bellek ve I/O sınırı uygular.
```
2. Servis seviyesinde izleme ve hata yönetimi yapılmasını sağlar.
```bash
systemctl status mariadb
systemd-cgtop
# systemd-cgtop servisin CPU ve bellek kullanımını gerçek zamanlı gösterir. 
``` 
3. Sistem kararlılığını artırır
```bash
[Service]
MemoryMax=1G
# Belirlenen sınır aşılırsa kernel OOM, yalnızca o servisi hedef alır.
```
4. Kaynak temelli performans teşhisi sağlar.
```bash
systemd-cgls
# Bu komut cgroup hiyerarşisini göstererek hangi servislerin hangi süreçlere sahip olduğunu, hangi grubun yük oluşturduğunu hızlıca ortaya çıkarır.
# Mesela
systemd-cgls | grep ssh
```
## NETWORK ADVANVECD 
```bash
ip link # shows network interfaces
sudo lshw -class network # deeper information
nmtui || nmcli # Use NetworkManager for RHEL
man nmcli-examples # yapabileceklerinle ilgili örnekler. Z.b.
nmcli device wifi list
/etc/hosts   # hier stehen die Hostnamen
/etc/resolv.conf # standart DNS file
```
`/etc/nsswitch.conf`, isim çözümleme ve kimlik doğrulama işlemlerinde hangi kaynağın hangi sırayla kullanılacağını belirleyen yapılandırma dosyasıdır.
örnegin `passwd: files ldap ` Kimlik bilgileri önce yerel dosyalardan, sonra LDAP’tan alınır.

## LINUX LOGGING
journalctl -u cron.service # cron servisi (unit i ile ilgili) loglari gösterir.

## ADVANCED RESOURCING
```bash
/usr/etc/security/limits.conf # config file
ulimit -a # OLD SCHOOL all limitations in the system
```
SysRq (Magic SysRq Key), SysRq, çekirdek seviyesinde debugging, süreç sonlandırma, senkronizasyon ve güvenli reboot gibi işlemleri gerçekleştiren bir kurtarma arabirimidir.

Örnek. Alt + SysRq + REISUB; Kilitlenmiş sistemi güvenli şekilde yeniden başlatmak için kullanılan sıralı komut seti. Sol el ile Alt tuşuna, Sağ el ile PrintScreen/SysRq tuşuna basılı tut. SysRq tuşunu bırakmadan REISUB harflerine sirayla bas. 

## I/O Monitoring
`iotop` kullanilabilir. `dnf  install iotop` ile kurmalisin. 
### dd KOMUTU
dd, Linux’ta Veriyi bir kaynaktan alıp (if=input_file), hedefe (of=output_file) byte seviyesinde yazar. Genellikle imaj oluşturma, disk yazma, bootable USB hazırlama gibi işlemlerde kullanılır. 
```bash
dd if=ornek.iso of=/tmp/kopya.iso bs=1M # Bir dosyayı kopyalama. bs (block size), dd’nin her okuyup yazdığı veri parçasının büyüklüğüdür. 1M, 1 megabaytlık bloklarla okuma/yazma yapılacağı anlamına gelir.
dd if=/dev/sda of=/tmp/disk.img bs=4M # Bir disk imajı oluşturma
dd if=ornek.img of=/dev/sdb bs=4M status=progress # Bir imajı diske yazma. status=progress kopyalanan veri miktarını ve hızını terminalde canlı olarak gösterir.
```
### D-Bus `busctl list`
D-Bus (Desktop Bus), Farklı uygulamaların birbirleriyle veri veya komut paylaşmasını sağlar. Merkezi bir iletişim kanalı sağlar. Örneğin, bir uygulama diğerine “bu dosya açıldı” mesajı gönderebilir.
Bir daemon (genellikle dbus-daemon) sürekli çalışır ve mesajları gönderip alır. Tipik Kullanım: Masaüstü ortamları (GNOME, KDE) ve sistem servisleri arasında iletişim.
## BOOT OPERATIONS
### Emergency Mode
- Reboot your system.
- Interrupt the boot loader countdown (by pressing a key like "e" ).
- Locate the kernel command line (often starts with linux or linux16).
- Append systemd.unit=emergency.target to the end of that line.
- Boot using Ctrl+x or F10, depending on the bootloader instructions). 

### Runtime configuration 
Runtime configuration; uygulamanın davranışını kod değiştirmeden ve yeniden derlemeden yönetmeye yarar. Z.b. bir web sunucusunun port numarasını veya log seviyesini bir config.yaml dosyasından uygulama her başlatıldığında okuması. Uygulama çalışırken dosya değişirse ve sunucu bu değişikliği yeniden yükleyebiliyorsa, bu bir runtime configuration kullanım örneğidir.

## ADVANCED SECURITY
```bash
setfacl -m u:test:--x /root # biseyi calistirma || root listeleme hakki vermez. Sadece gecis yapmayi saglar. baska türlü dosyaya atlayamaz
setfacl -m u:test:r /root/deneme.txt 
```
```bash
chattr +i dosya.txt # Dosya değiştirilemez
chattr +a log.txt # Dosyaya sadece ekleme yapılabilir.
```

### PAM
```bash
ldd $(which login) # `which login` login binary’sinin tam yolunu verir Z.b. /usr/bin/login).
```
Bu komutun amacı, sistemde kullanılan login programının çalışırken hangi paylaşımlı kütüphanelere (shared libraries) bağlı olduguunu listeler. Kullanım amacı:
- PAM bağımlılıklarını modüllerini doğrulamak.
- Bozuk kütüphane bağımlılıklarını teşhis etmek.

Sistemde login işlemi başarısız oluyor ve journal kayıtlarında PAM ile ilgili hata görüyorsunuz:
```bash
ldd $(which login) # calistir
libpam.so.0 => not found
libpam_misc.so.0 => /lib64/libpam_misc.so.0 (...)
libc.so.6 => /lib64/libc.so.6 (...)
```
Bu çıktıdaki “not found” satırı, login binary’sinin PAM kütüphanesine erişemediğini gösterir. Bu durumda çözüm yolu işletim sistemine göre şu şekilde olur:

```bash
dnf reinstall pam
apt --reinstall install libpam0g
```
### FIREWALLING
Mevzu kernelda döner. Input girince forward veya output edilecek pakete karar verilir. `firewalld`  in Redhat and `Ufw` in Ubuntu. 
```bash
firewall-cmd --list-services # list, get, set, list, remove bunlari  --help icinde ara
```
Zone; firewalld ile tanımlanan bir güvenlik alanıdır. Zone, ağa bağlı arayüzler için farklı güvenlik seviyeleri ve kurallar seti belirler, hangi servis & portların izinli olduğunu kontrol eder. Örneğin:
```bash
firewall-cmd --runtime-to-permanent # firewall calisirken yaptigin degisiklikleri kalici yapar
```
### Rich Language
The rich language extends the current zone elements (service, port, icmp-block, icmp-type, masquerade, forward-port and source-port) with additional source and destination addresses, logging, actions and limits for logs and actions.
```bash
man 5 firewalld.richlanguage # en sonda örnekler var
```
## SeLinux & AppArmor
AppArmor’da profile; bir uygulamanın hangi dosyalara, dizinlere, ağ kaynaklarına ve sistem çağrılarına erişebileceğini belirleyen güvenlik politikası dosyasıdır. Uygulamanın davranışı bu profile göre kısıtlanır. Var olan profilleri görmek için aa-status komutunu kullanilir. Bir uygulamanın: hangi dizinleri okuyabileceği, hangi dosyalara yazabileceği, hangi binary’leri çalıştırabileceği, hangi ağ işlemlerini yapabileceği tamamen bu profil içinde tanımlanır. 


















### Network Tr6oubleshooting
```bash
ip a # Check if the interface is up
ping 192.168.1.1 # ping your gateway?
nslookup google.com # Can you resolve DNS ?
ss -tunlp # View all connections
firewall-cmd --list-all # Firewall issue?
```

```bash
nmcli # temiz network device adress bilgisi veriyor
nmcli device show
nmcli connection show ens23 # ens23 ün detaylarini gösterir
```
```bash
grep -ri ebenin* # recursively tüm dosya isimleri ve iceriklerinde ebenin kelimesiyle baslayan kelemeleri bulur
find / -name *.pdf 2> /dev/null
```
LAST komutu sisteme login olanlari bulur 

