```bash
systemd-analyze + blame # makinenin baslamasi icin süre + detaylat 
/lib/systemd/system # services are here
```

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
```
Network Troubleshooting
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
alias ports='netstat -tulanp'
```
nmcli; temiz network device adress bilgisi veriyor
nmcli device show
nmcli connection show ens23 ens23 ün detaylarini gösterir 
