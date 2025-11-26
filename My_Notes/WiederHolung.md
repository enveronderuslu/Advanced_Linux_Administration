```bash
systemd-analyze + blame # makinenin baslamasi icin süre + detaylat 
/lib/systemd/system # services are here
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
ctrl e ile satir sonuna ctrl a ile satirbasina gidersin. 

passwd icinde degisiklik yapacaksan `vipw` kullan (Ayni `visudo` da oldugu gibi) Yaptigin degisiklikleri kontrol eder ve hata varsa uyari verir- group lar icin `vigr`
/etc/login.defs icinde degisiklikler yaparak yeni olusturulacak user larin özellikleri ayarlanabilir. 

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

setfacl -m u:cemsit:rw deneme.txt enver kullanicisinin üzerinde Hakki olan deneme.txt dosyasina bir user atadim (gruba hak taniyacaksan u yerine g yaz) parent klasörlere hak vermezsen en altta izin aldigin dpsyaya ulasamazsin. Her kapi icin ayri izin lazim. 
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
# script.sh
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
Dosya/Klasör	Açıklama
/proc/cpuinfo	İşlemci bilgileri (model, çekirdek sayısı, hız)
/proc/meminfo	Bellek durumu (toplam, boş, swap)
/proc/uptime	Sistem çalışmaya başladığından beri geçen süre

`lsblk` List information about block devices. Özellikle sda lar. 
`/sys` provide info about devices and their attributes. Donanim ve sürücüler hakkinda bilgi verir. 

`/proc/sys` Kernelin tuning ve runtime yapılandırma parametrelerini sunar.
sysctl komutunun doğrudan arayüzüdür.

`/sys` (sysfs): Kernel içindeki donanım, sürücü ve çekirdek nesnelerini hiyerarşik şekilde gösterir. Gerçek zamanlı donanım durum bilgisi sağlar.

### Network Troubleshooting
```bash
ip a # Check if the interface is up
ping 192.168.1.1 # ping your gateway?
nslookup google.com # Can you resolve DNS ?
ss -tunlp # View all connections
firewall-cmd --list-all # Firewall issue?
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
nmcli # temiz network device adress bilgisi veriyor
nmcli device show
nmcli connection show ens23 # ens23 ün detaylarini gösterir
```
```bash
grep -ri ebenin* # recursively tüm dosya isimleri ve iceriklerinde ebenin kelimesiyle baslayan kelemeleri bulur
find / -name *.pdf 2> /dev/null
```
LAST komutu sisteme login olanlari bulur 

