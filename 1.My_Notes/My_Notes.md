
**Linux System Basics (Red Hat–based Systems)** 

# System and Hardware Info

```bash
hostnamectl  # Displays full system metadata and kernel info
lscpu        # Displays CPU architecture and hardware details
lsblk        # Lists all block devices and partitions
free -h      # Shows memory usage in human-readable format
df -h        # Displays mounted partitions and disk usage
date         # Displays current date, time, and timezone
sudo hostnamectl set-hostname <NewName> # Changing System Hostname
```

# Aliases & Bash Customization
Users have their own `.bashrc` file. To apply changes: `source ~/.bashrc`
The command `alias` shows all active aliases.
```ini
alias sysupdate='sudo dnf5 -y upgrade'
alias c='clear'
alias l='ls -laFtr --color=auto --group-directories-first'
alias ping='ping -c 5'
alias ports='ss -tulanp'
alias shut='sudo shutdown now'
PS1='$ ' 
```
head etwas.txt shows first 10 line of the file
tail etwas.txt shows last 10 line of the file
tail -n 20 etwas.txt
sudo tail -f  /var/log/messages eklendikce yenileri  görürsün

### Use Case: profile.d usage
To set "vim" as the system-wide default editor:
`sudo vim /etc/profile.d/editor.sh`

Add the following lines:
```ini
#!/bin/bash
export EDITOR=$(which vim)
export VISUAL=$(which vim)
```
Make it executable: `sudo chmod +x /etc/profile.d/editor.sh`

## Shell Automation Utilities
* **xargs:** Converts standard input into arguments for other commands.
    * Example: `cat folder.txt | xargs mkdir` (Reads folder names from a file and creates directories for each).

### Understanding `xargs`

`xargs` is a utility that reads items from standard input (separated by blanks or newlines) and executes a command using those items as arguments. It is essential when a command does not accept input directly via a pipe (`|`).

**Practical Examples**

* **Deleting multiple files found by `find`:**
    Instead of errors when too many files are found, `xargs` processes them safely:
    ```bash
    find . -name "*.tmp" | xargs rm
    ```

* **Creating directories from a list:**
    If you have a file `list.txt` containing folder names:
    ```bash
    cat list.txt | xargs mkdir
    ```

* **Counting lines in multiple files:**
    ```bash
    ls *.txt | xargs wc -l
    ```
---

# System Architecture and Boot Process

## Boot Process
- BIOS/UEFI initializes hardware and loads the bootloader.
- GRUB2 (GRand Unified Bootloader) presents boot options, loads the kernel.
- Kernel Initialization and hardware driver loading.
- systemd launches essential services (PID 1) and brings the system to a usable state.

## SYSTEMD 
Shortly systemd is the service management. Systemd is the primary service manager for modern Linux distributions.
- **System Boot:** First process (PID 1) that starts all system components.
- **Service Management:** Handles daemons like web and database servers.
- **Dependency Management:** Ensures services start in the correct sequence.
- **Resource Management:** Controls system resources (CPU, RAM) using cgroups.
- **Journaling:** Centralized logging via `journald`, accessible with `journalctl`.
- **Additional Features:** Includes timers (cron alternative), networking, and session management.

```bash
systemd-analyze         # Shows total boot time
systemd-analyze blame   # Shows time taken by each service to start
/usr/lib/systemd/system # Default system unit files (installed by packages)
/etc/systemd/system     # User-defined unit files and customizations
```

### Best Practices
Configuration Management
- Do not modify vendor files; use overrides under /etc.
- If there are many steps in the same service, use a separate script instead of ExecStart=.

Dependency and Order Management
- Requires= service requirement, After= startup order
- Avoid unnecessary dependencies, check the boot time.

Monitoring
- Follow service status continuously with systemctl status, journalctl -u.
- Use Persistent= on the Timer side to compensate for missed schedules.

Security
- Isolate the service running environment as much as possible:
- ProtectSystem=full, ProtectHome=yes, PrivateDevices=yes
- Use CapabilityBoundingSet=
- Regularly review the override.conf structures of the services.
- Standardize isolation settings in all unit files for security.

If you establish a wrong dependency, the system waits for that unnecessary service during every boot.
Wrong design: A log collection service:
```ini
Requires=mysql.service
After=mysql.service
```
In this case, MySQL is expected to open first for the Log service. If MySQL opens late, the log service also waits. Boot time is unnecessarily extended. Correct:

```ini 
Wants=mysql.service
After=mysql.service
```
In this case, the dependency is not mandatory; the system boots without starting MySQL if necessary. When organizing service dependencies, choose "Wants" instead of "Requires" as much as possible.

## Systemctl 

sudo systemctl edit unit.type # e.g. sshd.service
sudo systemctl show sshd.service # shows all service details

- socket: A socket unit (e.g. sshd.socket) listens on a port and triggers the service when a connection is received.  
sshd.socket listens on port 22 sshd.service starts when a connection occurs  
---

**Example**
```ini
[Unit]
Description=Basic Python HTTP Server

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
```

After saving, run:
```bash
systemctl daemon-reload
systemctl enable myhttp.service
```

---

### Core Concepts and Commands

**Unit**: A configuration object managed by systemd (service, socket, mount, timer, target). Stored under:
- `/usr/lib/systemd/system/`
- `/etc/systemd/system/`

**Target**: A unit type grouping other units to define a system state.  
Examples:
- multi-user.target
- graphical.target
- rescue.target

```bash
systemctl start <unit> # Starts a unit immediately.  

systemctl stop <unit> # Stops a running service. Use case: Stopping firewalld.service

systemctl restart <unit> # Stops and starts the unit.  

systemctl status <unit> # Shows active state, logs, metadata.  

systemctl enable <unit> # Activates automatic start at boot.  

systemctl disable <unit> # Prevents boot-time start. Disabling unused services

systemctl daemon-reload # Reloads unit files after edits.

systemctl set-default <target> # Sets system boot target. Use case: Switching to `multi-user.target`.

systemctl get-default # Displays current default target.  
```
---

## SYSTEMD CGROUPS

What it does:
1. Limits resource usage of services (CPU, RAM, I/O).

```bash
mkdir -p /etc/systemd/system/httpd.service.d
cat > /etc/systemd/system/httpd.service.d/limits.conf
```

```ini
[Service]
CPUQuota=40%
MemoryMax=800M
IOReadBandwidthMax=/ 10M
```

```bash
systemctl daemon-reload
systemctl restart httpd
```
---

2. Service monitoring and diagnostics.

```bash
systemctl status mariadb
systemd-cgtop
systemd-cgls
systemd-cgls | grep ssh
```
---

3. Improves system stability.

```ini
[Service]
MemoryMax=1G
```
---

### .service and .target Files

`.service`  define individual services.  
`.target`  group services for collective management.  

Locations:
- `/usr/lib/systemd/system/`
- `/etc/systemd/system/`

Example:
- Default: `/usr/lib/systemd/system/sshd.service`
- Custom: `/etc/systemd/system/sshd.service`

Use:
```bash
systemctl edit etwas.service
```
---

**Example .service File**

```ini
[Unit]
Description=Python HTTP Server

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target
```

```bash
systemctl enable myhttp.service
```
---

**Example .target File**

```ini
[Unit]
Description=Custom Services Target
Requires=myhttp.service
Requires=nginx.service
After=network.target
```
---

### Default Targets

- `multi-user.target`
- `graphical.target`

---
 

# Package Management with DNF
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

### FLATPAK
Ubuntu'daki Snap gibi, RHEL tarafında da bağımlılıkları içinde barındıran ve sistemden izole çalışan standart paketleme formatı Flatpak'tir. Red Hat sistemlerinde varsayılan olarak desteklenir ve geliştirilir.

```bash
sudo dnf install flatpak # install Flatpak
flatpak remote-add --if-not-exists flathub [https://flathub.org/repo/flathub.flatpa](https://flathub.org/repo/flathub.flatpa) # add repo
flatpak search firefox # search
sudo flatpak search typora
# Name      Description           App ID              Version  Remotes
# Typora    Markdown read/write   io.typora.Typora    1.12.4   flathub
flatpak install flathub io.typora.Typora # install
```


**Case Study**
```bash
sudo dnf install google-chrome-stable.rpm
E: Unable to find a match: google-chrome-stable_current_x86_64.rpm
```
dnf, bu komuttaki "google-chrome-stable_current_x86_64.rpm" ifadesini, bir paket deposundaki paket ismi sanıyor. Aslında elindeki yerel bir dosyayı kurmaya çalışıyorsun. Bu yüzden sistem, benim depolarımda `google-chrome-stable_current_x86_64.rpm` diye bir paket yok diyor ve hata veriyor.

`sudo dnf install google-chrome-stable` komutunda doğru çalışır.  dnf, .rpm dosyalarını paket deposu (package repository) gibi algılar. Bu yüzden "Unable to find a match" hatası verir.
.rpm dosyası ile çalışmak için uygun değil.
`sudo rpm -i google-chrome-stable_current_x86_64.rpm`  -> Doğru kullanım

`sudo dnf install google-chrome-stable` dediğinde, dnf markete gider, raftan ilgili paketi bulur ve kurar. 
3. dnf = Market görevlisi takip eder.
4. rpm dosyası = Poşet içindeki ürün `sudo rpm -i ürün.rpm`
5. Dosyayı indirdiğin yerde terminalde `sudo dnf install ./google-chrome-stable_current_x86_64.rpm` yazsan direkt çalışır.

---



# User and Group Management

## Commands
```bash
whoami  # Shows current logged-in user 
who  # Users currently connected to the system

useradd  # minimal user creation (manual setup)
adduser  # creates home directory and sets password

groupadd

userdel <user>  # home directory is not deleted
userdel -r <user>  # home directory is deleted

usermod -G <GROUP> <USER>  # replaces groups
usermod -aG <GROUP> <USER>  # appends groups

visudo  # opens sudoers file safely

id <USER>  # shows user group membership
```

---

## System Files

- `/etc/passwd` → user account information  
- `/etc/shadow` → encrypted passwords  

Use:
- `vipw` → safely edit passwd  
- `vigr` → safely edit group  

- `/etc/login.defs`, `/etc/security/pwquality.conf`, `/etc/security/faillock.conf` → password and authentication settings  

The `/etc/skel` directory contains default files that will be automatically copied to the home directory of a new user when it is created.

---

## Password Policies

```bash
chage -l
chage <USER_NAME>
```

PASSWORD AGING: `chage -m <mindays> -M <maxdays> -d <lastday>`

---

## Session Management

loginctl is the newest tool. w or who commands also work.

```bash
loginctl list-sessions
loginctl show-session <session_number>
loginctl terminate-session <session_number>
```
---

# SYSTEM MONITORING




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
`ps aux | grep  ssh` bununla tüm ssh processlerini ve PID lerini görürsün

ctrl + z islmei arkaya atar. jobs ile bu islemleri görürsün. %1 sana arkada calisan 1 numarali processi getirir. fg veya bg foreground background

ps auxZ | grep -E 'httpd|COMMAND' # 'httpd|COMMAND' ifadesi, hem httpd içeren satırları hem de başlık satırını (COMMAND) filtreler. Böylece çıktıda işlemler ve sütun başlıkları birlikte görünür.

ps fax # parent child processes
kill basiert auf PID
killall basiert auf Processname 

w shows all current sesions
```bash 
pgrep -l -u bob # bob isimli user la ilgili processes
```

```bash
pkill -SIGKILL -u <user> # user ile ilgili tüm prosesleri kill yapar
```

```bash
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


---


# Networking

What is the loopback device? localhost  
NIC bonding: Combining multiple NICs together  

---

## UBUNTU

systemctl status systemd-networkd  

Netplan: set `renderer` to `NetworkManager` instead of `networkd`.  
Disable `systemd-networkd` and use NetworkManager via netplan renderer.

networkctl  
networkctl status # Shows interface state and recent status information  

DNS configuration:

| File                               | Priority | Role               | Effect       |
|------------------------------------|----------|--------------------|--------------|
| /etc/netplan/50-cloud-init.yaml    | 1        | DNS definition     | Active       |
| /etc/systemd/resolved.conf         | 2        | Behavior settings  | Supporting   |
| /etc/resolv.conf                   | 3        | Auto-generated     | Indirect     |

Netplan configuration determines the effective DNS settings.

resolvectl  
resolvectl status  

---

## RHEL 

NetworkManager  

Config file:  
`/etc/NetworkManager/system-connections/enp0s3.nmconnection`  

man nmcli-examples  

Cockpit web interface runs on port 9090  

sudo systemctl status NetworkManager # Shows service status and recent logs  
sudo journalctl -u NetworkManager | less # Full logs  

---

## COMMANDS

ip l # data link layer info  

MTU: maximum packet size (default ~1500 bytes)

```bash
ip -br -4 a
ip -o -4 a | column -t
ip -c r | column -t
```

```bash
dig example.com
dig -x IP_Address
dig @4.2.2.2 google.com # Query DNS using specific server
```
---

## Working with HOSTS file

Format: IP FQDN hostname  

```bash
vim /etc/hosts
172.17.17.20 ubuntu.example.local ubuntu
```

Local name resolution without DNS.

Example:
```bash
ssh ansible@ubuntu
```
client.example.local → Fully Qualified Domain Name (FQDN)
---

## NSSWITCH

`/etc/nsswitch.conf` defines lookup order for user, group, and hostname resolution.

Example:
```conf
passwd: files sss
group:  files sss
hosts:  files dns
```

Meaning:
- passwd: local files → SSSD  
- hosts: /etc/hosts → DNS  

---

## ss

| Status            | Meaning                                      |
|-------------------|----------------------------------------------|
| LISTEN            | Port is listening                            |
| ESTABLISHED       | Active connection                            |
| CLOSE_WAIT        | Remote closed, local still open              |
| TIME_WAIT         | Closed, waiting before reuse                 |
| SYN_SENT SYN_RECV | Connection establishment in progress         |

```bash
ss -tulnw
```

---

## Process Check

```bash
pgrep -c ssh  # Count matching processes
pgrep -a ssh  # List matching processes
```

---

## SFTP 

Use SFTP for interactive file transfer over SSH.

```bash
      sftp <user>@<remote_IP>
sftp> get testfile
sftp> put /path/to/file
sftp> mkdir etwas_file
sftp> lls
```

---

## APACHE 

/var/www/html/index.html

---

## CASE STUDY 

Static routing between networks via intermediate host.
There re two subnets 192.168.1.0/24 and 10.10.10.0/24
Host A: 192.168.1.A  
Host B (Router/Gateway): 192.168.1.B / 10.10.10.B  
Host C: 10.10.10.C  

To enable communication between A and C, configure static routes: 

From A to C:
```bash
ip route add 10.10.10.0/24 via 192.168.1.B
```

From C to A:
```bash
ip route add 192.168.1.0/24 via 10.10.10.B
```

---


# Storage and Disk Management

## Disk Identification and Usage
* `fdisk -l`: Lists all available disks and partitions.
* `lsblk`: Displays block devices in a tree-like structure (recommended for better visibility).
* `df -h`: Shows disk space usage in human-readable format.
* `du -sh *`: Displays the size of files and directories in the current location.
* `ncdu`: Interactive disk usage analyzer for navigating directory sizes.

## Mounting Procedures
1.  **Format:** `sudo mkfs.ext4 /dev/nvme0n2` (Formats the disk with the ext4 filesystem).
2.  **Create Mount Point:** `sudo mkdir -p /mnt/disk2` (`-p` creates parent directories if they do not exist).
3.  **Mount:** `sudo mount /dev/nvme0n2 /mnt/disk2`
4.  **Persistent Mount:** Add the entry to `/etc/fstab` to ensure the disk mounts automatically on boot.

## Advanced Resource Management
* **/etc/security/limits.conf:** Configuration file for setting user resource limits (e.g., max open files, memory usage).
* `ulimit -a`: Displays current resource limits for the shell session.

## System Recovery (Magic SysRq)
The Magic SysRq key is a kernel-level debugging interface used for system recovery and emergency tasks.

* **Emergency Reboot:** `Alt + SysRq + R, E, I, S, U, B` (Safe sequence to reboot a frozen system).
    * **R:** Sets keyboard to raw mode.
    * **E:** Sends SIGTERM to all processes.
    * **I:** Sends SIGKILL to all processes.
    * **S:** Syncs all mounted filesystems.
    * **U:** Remounts filesystems as read-only.
    * **B:** Reboots the system.



# Security
## Firewall Management (firewalld)
* `firewall-cmd --list-services`: Lists currently active services.
* `firewall-cmd --runtime-to-permanent`: Saves runtime configurations to permanent rules.
* **Rich Language:** Extends zone elements with source/destination addresses, logging, and specific actions. 
    * `man 5 firewalld.richlanguage` (refer to the examples section).



## Linux OS Hardening
* **Authentication Policies:**
    * `/etc/login.defs`: Defines system-wide user profile configurations (password aging, UID/GID ranges).
    * `/etc/pam.d/system-auth`: Configures PAM (Pluggable Authentication Modules) for authentication requirements.
* **Package Management:**
    * **Red Hat/CentOS/Fedora:** `rpm -qa` lists all installed packages.
    * **Debian/Ubuntu:** `dpkg -l` lists all installed packages.
    * *Note: Always verify dependency impacts before removing packages.*
* **SSH Security (`/etc/ssh/sshd_config`):**
    * Change default SSH port.
    * Set `PermitRootLogin no`.
    * Apply changes: `systemctl restart sshd`.
* **Access Control:**
    * **Firewall:** Enable `firewalld` (use `firewall-config` for GUI or `firewall-cmd` for CLI).
    * **SELinux:** Enable Security-Enhanced Linux; configuration is located in `/etc/selinux/config`.

---


# Filesystem Management

## Searching and Locating
* `find / -name "*.doc" 2> /dev/null`: Searches for files ending in `.doc` from the root directory.
* `locate`: Uses `updatedb` for faster file searching.
* `whereis`: Locates the binary, source, and manual page files for a command.
* `which`: Displays the full path to a shell command.
* `grep -ri [pattern] [path]`: Recursively searches for a pattern within files and subdirectories.



## Permissions and Ownership
* `chown [user]:[group] [file]`: Changes file owner and group. Use `-R` for recursive changes.
* `chattr`: Modifies file attributes:
    * `+i`: Immutable (cannot be modified, deleted, or renamed).
    * `+a`: Append-only (data can only be added).
* `umask`: Determines default file creation permissions (e.g., `022` results in `755` for directories).

## Special Permissions
* **SUID (`u+s`):** Runs the file with the permissions of the file owner.
* **SGID (`g+s`):** Inherits the group of the directory for new files created within it.
* **Sticky Bit (`+t`):** Restricts file deletion within a directory to the owner or root.

## Access Control Lists (ACLs)
Standard permissions are often insufficient; `setfacl` provides granular control.
* `setfacl -m u:[user]:[perms] [file]`: Grants specific user permissions.
* `setfacl -d -R -m u:[user]:[perms] [dir]`: Applies default (inherited) permissions recursively.
* `getfacl [file]`: Displays current ACL settings.

## Links (Hard vs. Soft)
* **Hard Link:** `ln [source] [link]`. Shares the same inode. Data remains accessible even if the original file is deleted.
* **Symbolic Link:** `ln -s [source] [link]`. A pointer to the file path. Deleting the source breaks the link.



## System Utilities
* `tree [dir]`: Displays directory contents in a tree structure.
* `du -h --max-depth=1 /`: Summarizes disk usage for directories one level deep.
* `/etc/fstab`: Static information about the file systems (used for automatic mounting).

## SELinux Tools
* `getenforce` / `setenforce`: Checks or changes SELinux status.
* `semanage`: Manages SELinux policy configurations.
* `restorecon`: Restores the default security context for files.
* `getsebool`: Queries SELinux boolean values.


# System Monitoring and Performance

## Process and System Monitoring
* `ps fax`: Displays process tree (parent/child relationships).
* `top` / `htop`: Real-time monitoring of CPU, memory, and running tasks.
    * In `top`, press `Shift + M` to sort by memory usage.
* `vmstat`: Reports virtual memory statistics, CPU activity, and system load.
* `iotop`: Displays real-time disk I/O usage per process. (Install via `dnf install iotop`).
* `nmon`: Comprehensive system monitoring tool for CPU, memory, network, and disks.



## Advanced I/O and Disk Utilities
### The `dd` Command
Used for low-level copying and conversion of raw data.
* **Copy file:** `dd if=source.iso of=destination.iso bs=1M`
* **Create disk image:** `dd if=/dev/sda of=/tmp/disk.img bs=4M`
* **Write image with progress:** `dd if=source.img of=/dev/sdb bs=4M status=progress`

## Kernel and System Parameters
### The `/proc` and `/sys` Filesystems (Virtual Interfaces)
* **/proc:** A virtual filesystem providing kernel and process information.
    * `/proc/cpuinfo`: CPU specifications.
    * `/proc/meminfo`: RAM and Swap statistics.
    * `/proc/uptime`: System operational time.
* **/sys (sysfs):** Exposes kernel objects, hardware devices, and drivers in a hierarchical structure.
* **/proc/sys:** Interface for kernel runtime tuning (manually adjustable parameters).

### Kernel Tuning
* **sysctl:** Command-line tool to modify kernel parameters at runtime (stored in `/etc/sysctl.conf` for persistence).

## Mount Management
* `findmnt`: Lists all mounted filesystems.
* `umount [device]`: Unmounts a filesystem.
* **Common Mount Options:**
    * `defaults`: Uses standard settings (rw, suid, dev, exec, auto, nouser, async).
    * `noauto`: Does not mount automatically at boot.
    * `ro` / `rw`: Read-only or Read-write access.

## Boot Operations
### Emergency Mode (Recovery)
1. Reboot the system and interrupt the bootloader (usually press `e` at the GRUB menu).
2. Locate the line starting with `linux` or `linux16`.
3. Append `systemd.unit=emergency.target` to the end of the line.
4. Press `Ctrl+x` or `F10` to boot into the emergency shell.

## Log Management
* **journalctl:** The standard tool for querying and displaying logs from `systemd-journald`.
* **Syslog vs. Rsyslog:** * **Syslog:** The legacy logging protocol/daemon.
    * **Rsyslog:** The modern, feature-rich, high-performance successor (standard in most distributions).
---

# Troubleshooting and Recovery

## Understanding Troubleshooting
Troubleshooting is a structured process to identify, diagnose, and resolve system issues.
* **Detection:** Identifying symptoms.
* **Diagnosis:** Analyzing logs and states to find the root cause.
* **Fix:** Applying a solution.
* **Verification:** Testing the system to ensure stability.



## Log Monitoring
Logs are the primary source of diagnostic data.
* `/var/log/secure`: Authentication and login/logout logs.
* `journalctl -u <service_name>`: Displays logs for a specific `systemd` unit.
* `tail -f /var/log/<file>`: Follows log files in real-time.

## Common Diagnostic Tools
| Tool | Purpose |
| :--- | :--- |
| `journalctl` | Query `systemd` logs |
| `dmesg` | Kernel ring buffer (hardware/driver issues) |
| `strace` | Traces system calls made by a process |
| `ss` / `netstat` | Network socket statistics |
| `iostat` | CPU and I/O statistics |
| `coredumpctl` | Manage and inspect process core dumps |

## System Resource Metrics (`top` Fields)
When monitoring `top`, understand these key metrics:
* **PR (Priority):** Scheduling priority (system-assigned).
* **NI (Nice):** User-defined priority (-20 to 19).
* **VIRT:** Total virtual memory size.
* **RES:** Physical RAM used (Resident Set Size).
* **SHR:** Shared memory size.

## Boot and Recovery
### Emergency/Rescue Mode
If the system fails to boot:
1.  Reboot and interrupt the GRUB menu (press `e`).
2.  Append `systemd.unit=emergency.target` to the line starting with `linux`.
3.  Boot (`Ctrl+x`).
4.  If `initramfs` is corrupt, use `dracut -f` to regenerate it.

## Advanced File Management and Automation
* **ACLs (`setfacl` / `getfacl`):** Provides granular permissions beyond standard UGO (User/Group/Other) settings.
* **`chattr`:** Sets immutable (`+i`) or append-only (`+a`) file attributes.
* **`umask`:** Determines default permissions for newly created files/directories (e.g., `umask 022` results in `755` for directories).
* **Command Logic:**
    * `&&`: Runs the second command only if the first succeeds.
    * `||`: Runs the second command only if the first fails.
    * `;`: Runs commands sequentially, regardless of success/failure.



## System Architecture Highlights
* **`/proc`:** Virtual filesystem for kernel and process state (RAM-based).
* **`/sys`:** Hierarchical interface for hardware devices and drivers.
* **Swap:** Virtual memory on disk used when physical RAM is exhausted (recommended size is 2x RAM).
* **Sosreport:** Generates a comprehensive system diagnostic archive for troubleshooting.

## Essential VIM Shortcuts
* `yy` / `dd`: Yank (copy) / delete current line.
* `p`: Paste.
* `set number`: Display line numbers.
* `/pattern`: Search forward for a pattern; `n` for next match.
* `cw`: Change word (deletes word and enters insert mode).
---
 
# Miscellaneous Utilities and Configuration

### Quick Reference Commands
* `cut -d : -f 3 /etc/passwd`: Selects the 3rd column from `/etc/passwd` using `:` as a delimiter.
* `git config --global ...`: Sets Git user email and name globally.
* `ssh-keygen -t ED25519 -b 4096`: Generates a  SSH key pair. ED25519 artik rsa yerine bu kullamiliyor. 
* `ssh-copy-id -i ~/.ssh/id_rsa.pub [user]@[host]`: Copies the public SSH key to the remote host for passwordless login.

### VIM Configuration
To enable syntax highlighting and color schemes, create or edit `~/.vimrc`:
```vim
syntax on
colorscheme industry
```

### Remote File Transfer (SCP)
* **Local to Remote:** `scp -r /local/path user@host:/remote/path`
* **Remote to Local:** `scp -r user@host:/remote/path /local/path`

### User Account Management
* **Rename User and Home Directory:**
  ```bash
  sudo usermod -l newname oldname
  sudo usermod -d /home/newname -m newname
  ```

### SSH Aliases and Port Forwarding
If using VirtualBox or complex networking, use aliases to simplify connections:
* `alias machine_name='ssh -p [port] [user]@[ip]'`
* Use `ssh-copy-id -p [port] [user]@[ip]` to transfer keys across custom ports.

### Passwordless Sudo (`visudo`)
To grant specific users `sudo` privileges without a password:
* **Full Access:** `boss ALL=(ALL) NOPASSWD: ALL`
* **Command Specific:** `test ALL=(ALL) NOPASSWD: /sbin/reboot`

## D-Bus busctl list
D-Bus (Desktop Bus), Farklı uygulamaların birbirleriyle veri veya komut paylaşmasını sağlar. Merkezi bir iletişim kanalı sağlar. Örneğin, bir uygulama diğerine “bu dosya açıldı” mesajı gönderebilir.
Bir daemon (genellikle dbus-daemon) sürekli çalışır ve mesajları gönderip alır. Tipik Kullanım: Masaüstü ortamları (GNOME, KDE) ve sistem servisleri arasında iletişim.
## Runtime configuration 
Runtime configuration; uygulamanın davranışını kod değiştirmeden ve yeniden derlemeden yönetmeye yarar. Z.b. bir web sunucusunun port numarasını veya log seviyesini bir config.yaml dosyasından uygulama her başlatıldığında okuması. Uygulama çalışırken dosya değişirse ve sunucu bu değişikliği yeniden yükleyebiliyorsa, bu bir r
```