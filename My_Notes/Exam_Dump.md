```bash
sudo find  / -size +10M > /tmp/bigfiles # 10mb den büyük dosyalari bulup yazdirdik. 
```
```bash
ln /tmp/bsiles /bfiles # hardlink created
ln: failed to create hard link '/bfiles' => '/tmp/bfiles': Invalid cross-device link
```
Bu hata, hard link oluşturmaya çalıştığınızda kaynak ve hedefin farklı dosya sistemlerinde olduğunu gösterir.
**Hard linkler aynı dosya sistemi içinde çalışır**
Cok istiyorsan symbolic link : 
```bash
sudo ln -s /tmp/bfiles /bfiles
```
---

- Set defaults for all new users such that passwords have a maximum validity of 90 days: 
```bash 
sudo vim /etc/login.def #  icinde max days 90 yap`
```

- When creating new users, copy an empty file with the name data to their home directory
```bash
sudo cd /etc/skel && touch data.txt
```

- Create users anna1 and anouk and set their secondary group membership to profs
```bash
sudo useradd anna1 && sudo useradd anna2
sudo groupadd Profs
sudo usermod -aG Profs anna1 && sudo usermod -aG Profs anna2
```
- Create a directory/data/Profs and ensure that members of the group Profs have full access to /data/Profs
```bash
sudo mkdir -p /data/Profs/ # p parametresiyle parent klasör yani data  klasörüde created
sudo chown :Profs /data/Profs/
```
---

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

---
- Create the file /tmp/protectedfile, containing the text "I am protected". Ensure this file can be added to, but not removed, and current contents cannot be changed. Sadece sonuna biseyler eklensin baska bisey yapilamasin. 

```bash
echo "I am protected" > /tmp/protectedfile
sudo chattr +a /tmp/protectedfile # the +a flag (append-only) 
echo "but I can be added to" >> /tmp/protectedfile # sadece bu sekilde sona ekleme yaparsin
```
---
Start a container based on the docker.io/library/nginx:latest image:
The container is started by the root user, on localhost port 8080


```bash
docker run -d  # run in the background 
-u 0  # started by the root user
-p 8080:80   # localhost port 8080
-e type=webserver # An environment variable is set as type=webserver
-v /root/data:/data # a directory/data is presented. All files written to that directory are mapped to /root/data
--name my-nginx-web docker.io/library/nginx:latest
```
---

- Create a file /root/suid-files-base.txt that contains a list of all files with SUID permission 644
```bash
sudo touch /root/suid-files-base.txt
find / -perm 644 -type f 2</dev/null > /root/suid-files-base.txt
```
- Add the file /tmp/runme, and ensure it has SUID as well as execute permissions 
```bash
cd /tmp
sudo touch /tmp/runme # script  olustur
sudo vim /tmp/runme # scriptin icine girip yaziyoruz
  #!/bin/bash
  echo "This script ran" 
sudo chmod +x /tmp/runme # scripti executable yaptik
./runme # scripti ccalistirdik
```

---

- Set the hostname of your computer to examhost.example.local
```bash
sudo hostnamectl set-hostname examhost.example.local
```
- Ensure that this name resolves to your computers primary IP address
```bash
sudo vim /etc/hosts # client ta
192.168.178.146 examhost.example.local examhost # (IP adresi belongs to server) Add this entity
ping -c 3 examhost.example.local # test icin (client ta calistir)
```
---
- Configure the Systemd Journal in such a way that it is stored persistently

You can configure the Systemd Journal to store logs persistently by modifying the Storage setting in the journald configuration file. This ensures that the logs are saved to the file system (specifically in /var/log/journal) and survive reboots, rather than being stored only in memory (/run/log/journal).

```bash
sudo vim /etc/systemd/journald.conf # make #Storage=persistent This is the recommended setting. It creates the persistent directory /var/log/journal/ if it doesn't exist. 
sudo mkdir -p /var/log/journal
sudo chown root:systemd-journal /var/log/journal
sudo chmod 2755 /var/log/journal
sudo systemctl restart systemd-journald
```
---








```bash

```


```bash

```