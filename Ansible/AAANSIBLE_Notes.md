kontrol edilecek tüm serverlarda ansible isimli user olusturuldu. 
Hata olmasi durumunda daha rahat takib edilebilir. 
herstellung von ssh-key-pairs

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@192.168.178.115
```


Avoiding sudo password prompts in Ansible
To get rid of sudo password issues on the target machine, add a custom rule to the sudoers file:

Open the sudoers file safely:
```bash
sudo visudo
```

Add the following line to allow passwordless sudo for the user ansible:
```bash
ansible ALL=(ALL) NOPASSWD: ALL
```

(Optional) If you only want to allow passwordless sudo for the reboot command:
```bash
ansible ALL=(ALL) NOPASSWD: /sbin/reboot
```

ansible kullanicilarini sudoers grubuna ekledik. islemler sirasinda sifre sormayacak

```bash
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL " >> /etc/sudoers.d/ansible
sudo usermod -aG sudo ( RHEL de " wheel " yazilir) ansible
```

password ile ssh baglantisi. defaultta password ile ssh baglantisi yoktur. önce "/etc/ssh/sshd_config" icinde buun acarsin. Sonra certifikayi ayarlayip passwd yi tekrar kapatirisin. 

```bash
w3m www.muster.com # curl gibi terminalden internet sitesine gider
```
 
```bash
systemctl list-unit-files | grep enabled | nginx # enable durumdaki servisleri verir
```


ansible-galaxy collection install ansible.posix
ansible-galaxy collection  list 
ansible-doc -l # cok genel ve cok satir var
ansible-doc copy 
# burada özel olarak copy modülü veriliyor detaylar ve örneklerle borlikte 
ansible-doc -t callback -l

```bash
```