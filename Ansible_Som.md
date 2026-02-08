 Seyyidina Ebu Ümâme, Seyyidina Es'ad bin Zürâre, Seyyidina Avf bin Haris, Seyyidina Rafi bin Malik, Seyyidina Kutbe bin Amir, Seyyidina Ukbe bin Amir, Seyyidina Cabir bin Abdullah


The Ansible vocabulary¶

```txt
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

```


ssh-copy-id

ansible fedora -m user -a "name=yeni_kullanici_adi state=present create_home=yes" --become -K

Dikkat: /etc/ansible icinde calistigindan -i inventory  kismina ihtiyac yok. direk hosts dosyasindan geliyor.

<host_veya_grup>: İşlemin yapılacağı hedef sunucunun inventory'deki adı (örneğin all veya web_servers).
-m user: Kullanıcı yönetimi için user modülünü çağırır.
-a "...": Modüle gönderilecek argümanları belirtir:
name=yeni_kullanici: Oluşturulacak kullanıcının adı.
state=present: Kullanıcının mevcut olması gerektiğini garantiler (yoksa oluşturur).
create_home=yes: Kullanıcı oluşturulurken bir ev dizini (/home/kullanici_adi) oluşturulmasını sağlar.
--become (veya -b): Komutu root yetkileriyle (sudo) çalıştırmak için gereklidir.

-K sudo icin kullaniliyor.

WHAT IS  ansible.cfg ?
The ansible.cfg file centralizes environmental parameters to ensure consistent execution. Common uses:

```ini
[defaults]
# --- Inventory & Connection ---
# Points to your inventory file so you don't need to type -i
inventory      = ./inventory.ini

# The default user for SSH connections
remote_user    = root

# Speed up lab setup by not asking to verify SSH fingerprints
host_key_checking = False

# --- Output & Behavior ---
# Use the 'yaml' callback for much more readable terminal output
stdout_callback = yaml

# Automatically find the correct Python path on the target (Ubuntu/Fedora/etc.)
interpreter_python = auto_silent

# Number of parallel processes (increase if you have many VMs)
forks          = 10

# Log Ansible output for auditing/debugging
log_path       = ./ansible.log

[privilege_escalation]
# --- Sudo Settings ---
# Automatically act as 'sudo' (replaces --become)
become = True

# Method of escalation (sudo is standard for Linux)
become_method = sudo

# The user you become (usually root)
become_user = root

# Set to True if you want to be prompted for the sudo password every time
# Set to False if you use passwordless sudo on your VMs
become_ask_pass = True

[ssh_connection]
# Optimize SSH by reusing connections (makes it much faster)
pipelining = True
```

Mesela;
```ini
[defaults]
inventory = inventory
remote_user = ansible
host_key_checking = false
interpreter_python = auto_silent

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = True
```
1. Deklarative Konfiguration (Soll-Zustand)
In der modernen IT sagen wir nicht mehr: "Erstelle einen User", sondern: "Der User 'test_user' soll existieren".
Nicht-idempotent: Ein Skript versucht jedes Mal, den User neu anzulegen und bricht beim zweiten Mal mit der Fehlermeldung "User existiert bereits" ab.
Idempotent (Ansible-Stil): Ansible prüft zuerst: Ist der User da? Wenn ja, passiert nichts (OK). Wenn nein, wird er angelegt (CHANGED).

ansible all -m  ansible.builtin.reboot --become -K
==================================
STATE = PRESENT
Ansible dünyasında state=present, bir kaynağın (kullanıcı, dosya, paket, vb.) sistemde "var olmasını" garanti altına alan deklaratif bir ifadedir.
İşte tam olarak ne anlama geldiği:
1. "Nasıl" Değil, "Ne" İstediğini Söylersin
Ansible'a "Kullanıcı oluştur" (bir eylem) demezsin. Bunun yerine "Bu kullanıcı sistemde mevcut (present) olmalı" (bir durum) dersin.
2. Idempotent (Aynılık) İlkesi ile Çalışır
state=present dediğinde Ansible şunları yapar:
Kontrol Et: Hedef makineye gider ve "Bu kullanıcı/paket zaten var mı?" diye bakar.
Karar Ver:
Eğer varsa: Hiçbir şey yapmaz (ok).
Eğer yoksa: Onu oluşturur (changed).
Sonuç: Komutu 100 kere de çalıştırsan, kullanıcı sadece 1 kere oluşturulur ve sistem durumu değişmez.
3. Diğer Yaygın Durumlar (State Seçenekleri)
state parametresi genellikle şu değerleri alır:
present: Mevcut olsun. (Eğer yoksa yükle/oluştur).
absent: Mevcut olmasın. (Eğer varsa sil/kaldır).
latest: Sadece mevcut olmasın, aynı zamanda en güncel sürümünde olsun (Özellikle paket yöneticilerinde kullanılır).
Örnekler:
Kullanıcı için: name=ahmet state=present (Ahmet kullanıcısı yoksa oluşturulur).
Paket (Nginx) için: name=nginx state=present (Nginx kurulu değilse kurulur).
Dosya için: path=/etc/test.conf state=absent (Eğer bu dosya varsa silinir).
Özetle: state=present, "Benim istediğim son durum budur, eğer sistem şu an böyle değilse onu bu hale getir" demektir. Ansible Guide to State üzerinden daha fazla teknik detaya ulaşabilirsin.


ansible all -m ping

ansible-doc -l | grep -i win # common usages are in examples

ansible-doc -s ansible.builtin.user  ,odülün  playbook icinde nasil kullabnilöacagini gösterir.

En temel anlamda  PLAYBOOK yapisi.

```yaml
# 1. PLAY LEVEL
- name: Title Describing the Purpose of the Playbook
  gather_facts: no
  hosts: server_group_name
  become: true
  remote_user: username

  # 2. VARIABLES
  vars:
    package_name: nginx
    user: ahmet

  # 3. TASKS LEVEL
  tasks:
    - name: Description of the First Task
      ansible.builtin.module_name:
        parameter1: value
        parameter2: "{{ variable_name }}"

    - name: Description of the Second Task
      ansible.builtin.shell: echo "Hello World"

  # 4. HANDLERS LEVEL
  handlers:
    - name: Restart Service
      ansible.builtin.service:
        name: nginx
        state: restarted
```

FACT ve debugging

Fact
Fact is the system information (IP address, operating system, RAM, disk status, etc.) that Ansible automatically collects when it connects to the target server. This process is called "gathering facts."
Simple Example:
A task that displays the operating system of the target machine:
```yaml
- name: Show operating system
  ansible.builtin.debug:
    msg: "This server is running on {{ ansible_distribution }}."
```

Debug
Debug is a module used to print variable values, messages, or "fact" information to the terminal screen while the playbook is running. It is used for troubleshooting and verification purposes.
Simple Example:
Printing the content of a variable to the terminal:
```yaml
- name: Check the variable
  ansible.builtin.debug:
    var: ansible_all_ipv4_addresses
```





```yaml

---
- name: ibstall and start hhtpd
  hosts: all
  tasks:
    - name: install hhtpd
      ansible.builtin.package:
        name: httpd
        srare: latest

    - name: start the service
      ansible.builtin.service:
        name: httpd
        enabled:yes
        state:started

```
ansible-doc -s ansible.builtin.service

ansible-playbook dosya_adi.yml --check


ansible-doc firewalld (Bu artik calismiyor)

ansible-doc ansible.posix.firewalld

# buda calismiyorsa yüklü degildir. asagidakini kur

ansible-galaxy collection install ansible.posix


REGISTER  mevzusu

pöay esnasinda kullanilmak üzere bilgi  üretir. Somra veriable  gibi kullanir.


```yaml
- name: Uptime komutunu çalıştır
  ansible.builtin.command: uptime
  register: uptime_sonucu  # Çıktıyı bu isme kaydet

- name: Kaydedilen çıktıyı ekrana bas
  ansible.builtin.debug:
    msg: "Sunucu durumu şudur: {{ uptime_sonucu.stdout }}" # .stdout ile sadece metni al
```


direk "when  kullanamazmiydi? "


when komutu tek başına sadece Ansible'ın zaten bildiği "hazır" bilgileri (işletim sistemi, IP adresi gibi Facts verilerini) veya senin tanımladığın Variable'ları kontrol edebilir.

1. Register OLMADAN (Hata Verir):
```yaml
- name: Sadece klasör boşsa işlem yap
  ansible.builtin.file: path=/data/test.txt state=touch
  when: stdout == ""  # HATA! Ansible 'stdout' diye bir şeyi tanımaz.
                      # Hangi komutun çıktısı? Kimin stdout'u? Bilmiyor.
```

2. Register İLE (Doğru Yöntem):
```yaml
- name: Klasör içeriğini oku
  ansible.builtin.command: ls /data
  register: sonuc  # Çıktıyı "sonuc" kutusuna koyduk.

- name: Şimdi o kutuyu aç ve kontrol et
  ansible.builtin.file: path=/data/test.txt state=touch
  when: sonuc.stdout == ""  # ŞİMDİ ÇALIŞIR. Çünkü 'sonuc' kutusuna bakacağını biliyor.
```

FAIL modülü

```yaml
- name: Disk Kontrolü ve Kurulum Playbook'u
  hosts: servers
  tasks:

    - name: Root dizininin doluluk oranını kontrol et
      # 'df' komutu ile diski kontrol edip çıktıyı yakalıyoruz
      ansible.builtin.shell: "df / | tail -1 | awk '{print $5}' | sed 's/%//'"
      register: disk_usage

    - name: Disk %90'dan fazlaysa kurulumu durdur
      # 'fail' burada emniyet kilididir. Register'daki veri 90'dan büyükse durur.
      ansible.builtin.fail:
        msg: "Sunucuda yer yok! Mevcut doluluk: %{{ disk_usage.stdout }}. İşlem iptal edildi."
      when: disk_usage.stdout | int > 90

    - name: Uygulamayı kur
      # Eğer disk %90'dan az ise fail modülü atlanır ve bu görev çalışır.
      ansible.builtin.yum:
        name: nginx
        state: present
```

Normalde bir hata olunca Ansible durur. Buradaki durum farkli. normalde  %90 dan sonranra doluluk sistem icin bi gata degil. Fakat sana kritik durum. Baska islerede yer lazim.


Assert modülü


Assert modülü, aslında fail modülünün daha derli toplu ve "denetleyici" versiyonudur. Mantığı şudur: "Şu şartların doğru olduğunu doğrula (assert), eğer doğru değilse hata ver ve dur."
fail modülünde önce bir şart yazarsınız (when), o şart gerçekleşirse görev çalışır. Assert modülünde ise doğrudan beklentinizi yazarsınız.


```yaml
- name: Donanım Kontrolü
  hosts: all
  tasks:
    - name: RAM miktarını doğrula
      ansible.builtin.assert:
        that:
          - ansible_memtotal_mb >= 2048  # Şart 1: RAM yeterli mi?
          - ansible_os_family == "RedHat" # Şart 2: Doğru OS mu?
        fail_msg: "Sunucu gereksinimleri karşılamıyor!"
        success_msg: "Donanım uygun, kuruluma geçiliyor." 
``` 

1. ansible.builtin.copy
Dosyayı Kontrol Düğümünden (Ansible Server) alır ve Uzak Sunucuya (Managed Node) gönderir.
Kullanım: Küçük dosyalar (config, script vb.) için idealdir.
Örnek:

```yaml
- name: Config dosyasını gönder
  ansible.builtin.copy:
    src: /etc/local/nginx.conf
    dest: /etc/nginx/nginx.conf
```

2. ansible.builtin.synchronize
rsync aracını kullanır. Çok sayıda veya çok büyük dosyaları Kontrol Düğümünden Uzak Sunucuya (veya tam tersi) taşır.
Kullanım: Büyük dizinler, yedekler veya uygulama paketleri için en hızlı yöntemdir.
Örnek:
```yaml
- name: Uygulama klasörünü senkronize et
  ansible.builtin.synchronize:
    src: /opt/app_data/
    dest: /opt/app_data/

```

3. ansible.builtin.fetch
Dosyayı Uzak Sunucudan alır ve Kontrol Düğümüne (Ansible Server) getirir. (copy modülünün tam tersi).
Kullanım: Log dosyalarını veya sistem raporlarını merkeze toplamak için kullanılır.
Örnek:
```yaml
- name: Log dosyasını merkeze çek
  ansible.builtin.fetch:
    src: /var/log/syslog
    dest: /tmp/logs/{{ inventory_hostname }}.log
    flat: yes # Klasör hiyerarşisi oluşturmadan direkt dosyayı kaydeder.
```

Kritik Farklar Tablosu
Modül	Yön (Direction)	Alt Yapı	Temel Özellik
copy	Server → Sunucu	Python/SFTP	Tekil dosyalar ve şablonlar için standarttır.
synchronize	Server ↔ Sunucu	rsync	Delta transfer yapar (sadece değişen bitleri atar), çok hızlıdır.
fetch	Sunucu → Server	Python/SFTP	Sadece uzak sunucudan dosya toplamak içindir.
Önemli Not: synchronize modülünü kullanabilmek için her iki tarafta da rsync paketinin kurulu olması gerekir. Ansible Synchronize Documentation üzerinden detaylara bakabilirsiniz.

FING modül

ROLES

```text
roles/
  common/             # Rolün adı
    tasks/main.yml    # Yapılacak işler
    handlers/main.yml # Tetiklenecek handler'lar
    vars/main.yml     # Değişkenler
    templates/        # Jinja2 şablonları
```
ir Role (Rol) oluşturduğunda, Ansible otomatik olarak şu dosyalara bakar:
1. Dosya: roles/web_server/tasks/main.yml
Görevi: İşin mutfağıdır. Hangi komutların çalışacağını yazarız.
```yaml
- name: Nginx paketini kur
  ansible.builtin.package:
    name: nginx
    state: present

- name: Ayar dosyasını şablondan oluştur
  ansible.builtin.template:
    src: nginx.conf.j2    # 'templates' klasöründeki dosyaya bakar
    dest: /etc/nginx/nginx.conf
  notify: Servisi Yeniden Baslat # 'handlers' klasöründeki görevi tetikler
```

2. Dosya: roles/web_server/templates/nginx.conf.j2
Görevi: Değişkenleri içine yerleştirdiğimiz taslak dosyadır.
```ini
server {
    listen {{ web_port }}; # 'vars' klasöründeki değeri buraya çeker
}
```

3. Dosya: roles/web_server/vars/main.yml
Görevi: Rol içinde sabit kullanacağımız verileri tutar.
```yaml
web_port: 80
```

4. Dosya: roles/web_server/handlers/main.yml
Görevi: Sadece tetiklendiğinde (notify) çalışan görevleri tutar.
```yaml
- name: Servisi Yeniden Baslat
  ansible.builtin.service:
    name: nginx
    state: restarted
```

Peki Bunlar Nasıl Birleşiyor? (Main Playbook)
Senin ana dosyan (örneğin site.yml) artık devasa bir kod yığını olmak yerine sadece şunu söyler:
```yaml
- hosts: sunucularim
  roles:
    - web_server # Yukarıdaki 4 dosyayı tek bir isimle çağırdık
```


  COLLECTIONS

  Somut Koleksiyon Örneği: Nginx'i Docker ile Kurmak
Bu görevleri yapabilmek için önce şu komutla koleksiyonu indirirsin:
ansible-galaxy collection install community.docker
Ardından Playbook içinde şu şekilde kullanırsın:
```yaml
- name: Nginx Collection Örneği
  hosts: sunucular
  tasks:
    - name: Nginx konteynerini başlat
      # Aşağıdaki satır bir 'Collection' kullanımıdır
      community.docker.docker_container:
        name: my_nginx
        image: nginx:latest
        state: started
        ports:
          - "80:80"
```

KEYRING  konusu

Linux'ta Keyring, verilerin (anahtar, şifre, sertifika) bellekte veya diskte tutulmasını sağlayan bir nesne grubudur. İki ana katmanda incelenir: Kernel Keyring ve User-space Keyring.

1. Kernel Keyring (Çekirdek Seviyesi)
İşletim sisteminin çekirdek (RAM) üzerinde yönettiği bir veri yapısıdır. Bu bir "dosya" değildir; Kernel içinde bir Linked List (bağlı liste) yapısıdır.
Anahtarlar diskte değil, RAM'de (non-swappable kernel memory) tutulur. Sistem kapandığında bu veriler silinir.
Erişim: /proc/keys dosyası üzerinden kernel'daki mevcut anahtarları görebilirsiniz. keyctl komutu ile bu yapıya veri ekleyip çıkarabilirsiniz.
Kullanım: Disk şifreleme anahtarları (dm-crypt) veya ağ kimlik doğrulamaları (Kerberos biletleri) burada tutulur.

2. User-space Keyring (Disk Seviyesi)
GPG anahtarları veya paket yöneticilerinin (apt/dnf) kullandığı "keyring"ler aslında ikili (binary) formatta dosyalardır.
Format: Modern Linux sistemlerinde bu dosyalar genellikle GPG Keybox (.kbx) veya eski tip GPG Keyring (.gpg) formatındadır.
Dosya İçeriği: Bu bir metin dosyası değildir. İçinde OpenPGP standartlarına uygun olarak paketlenmiş dijital sertifikalar (public keys) bulunur.
Konum:
Sistem genelinde: /usr/share/keyrings/ veya /etc/apt/keyrings/
Kullanıcı özelinde: ~/.gnupg/pubring.kbx
Okuma: Bu dosyaları cat ile okuyamazsınız. İçeriğini görmek için gpg --no-default-keyring --keyring [dosya_yolu] --list-keys komutunu kullanmanız gerekir.

3. Keyring Daemon (Servis Seviyesi)
Masaüstü tarafında (GNOME/KDE) çalışan gnome-keyring-daemon gibi servisler, bu verileri diskte şifreli bir SQLite veritabanı veya özel bir binary formatta saklar.
Erişim Protokolü: Uygulamalar bu verilere D-Bus üzerinden, Secret Service API protokolünü kullanarak erişir.
Güvenlik: Şifreler diskte kullanıcının login şifresiyle türetilen bir anahtarla (Master Key) şifrelenmiş halde durur.
Özet Teknik Tablo
Katman	Saklama Biçimi	Yönetim Aracı
Kernel	RAM (Linked List)	keyctl
GPG/APT	Binary Dosya (.kbx / .gpg)	gpg
Masaüstü	Şifreli DB / Binary	libsecret / secret-tool

## SECURITY
ssh icin  'sudo visudo' icinde asagidaki satirlar eklenir. 
Defaults timestamp_timeout=30
Defaults timestamp_type=global

## TAG kullanimi

playbook un sadece belli bölümlerini kullanmak istediginide


```yaml
- name: Sunucu Kurulumu
  hosts: servers
  tasks:
    - name: Apache Paketini Kur
      apt:
        name: apache2
        state: present
      tags: install  # Bu taska 'install' etiketi verildi

    - name: Yapılandırma Dosyasını Güncelle
      copy:
        src: ./httpd.conf
        dest: /etc/apache2/httpd.conf
      tags: config   # Bu taska 'config' etiketi verildi
```
Nasi calisir?
```bash
ansible-playbook site.yml --tags "config"  # bir tag calistir
ansible-playbook site.yml --tags "install,config" # birden fazla tag
ansible-playbook site.yml --skip-tags "install" # bu haric hepsi calissin
```

## delegating isini anlamadim 
```yaml
name: Web Sunucularını Güncelle
  hosts: webservers
  tasks:
    - name: Sunucuyu Yük Dengeleyiciden Çıkar
      command: /usr/bin/remove_from_lb {{ inventory_hostname }}
      delegate_to: load_balancer_sunucusu  # Bu komut web sunucusunda değil, LB'de çalışır.

    - name: Uygulamayı Güncelle
      apt:
        name: my-app
        state: latest  # Bu task normal şekilde web sunucusunda çalışır.
```
webservers ile ilgili islem yapilacak fakat is LB üzerinde yapilacak. 
Soru: LB host olsa ve islem icin inventory dosyasindan  webservers cekilse olmazmi. Yani bi loop olusturulsa olmazmi?

Cevap: Olur, ancak yönetimi zorlaştırır.
Eğer ana hosts olarak Load Balancer'ı seçersen, Ansible o taskı web sunucuları sayısınca değil, sadece bir kez (LB için) çalıştırır. Web sunucularının isimlerini içeriye döngüyle (loop) sokman gerekir. delegate_to kullanmanın avantajı şudur: Ansible web sunucuları listesini baz alır; her bir web sunucusu için sırayla önce LB'ye gider, sonra web sunucusuna döner. Bu sayede karmaşık döngülerle uğraşmazsın. 

```yaml
- name: Hava Durumu Bilgisini Kaydet
  hosts: sunucular
  tasks:
    - name: İnternetten bilgi çek
      get_url:
        url: "wttr.in"
        dest: "./durum.txt"
      delegate_to: localhost  # İnternete sunucu değil, senin bilgisayarın çıkar.

    - name: Bilgiyi sunucuya kopyala
      copy:
        src: "./durum.txt"
        dest: "/tmp/hava_durumu.txt" # Dosya hedef sunucuya yazılır.

```

## Parallelism

Gomztoll hostun kaynak problemi olsun. Forks Ansible'ın aynı anda kaç "kol" (iş parçacığı) çıkaracağını belirler. 100 sunucun varsa ve forks değeri 5 ise, Ansible önce 5 sunucuyu bitirir, sonra diğer 5'e geçer. 
```bash
ansible-playbook test_playbook.yaml -f 10
```

Bu isi  playbook icinde yapacaksan buna serial deniliyor. 

```yaml
- name: Nginx Güncelleme
  hosts: webservers
  serial: 3  # Her seferinde sadece 3 sunucu güncellenir.
  tasks:
    - name: Nginx Yeniden Başlat
      ansible.builtin.service:
        name: nginx
        state: restarted
```
 ## optimizing SSH 
Which Ansible option allows multiple concurrent SSH connections with a remote host using one network connection?


A ControlPersist
B ControlMaster
C Pipelining
D SSH args



 ## optimizing Ansible
 
```bash
time ansible-playbook test_plybk.yaml # isin ne kadar sürecegini anlatiyor
time ansible-playbook -vvv test_plybk.yaml # detay verecek
```

## Timer ve callback plugins 

Aşağıdaki satırları ansible.cfg dosyasına yapıştır:
```ini
[defaults]
# Çıktı formatını daha okunur (YAML) yapar
stdout_callback = yaml
callbacks_enabled = ansible.posix.timer, ansible.posix.profile_tasks
```

## file lookup plugin
## AWX WEBGUI
