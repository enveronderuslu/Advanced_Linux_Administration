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
