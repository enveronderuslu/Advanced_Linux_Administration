kontrol edilecek tüm serverlarda ansible isimli user olusturuldu. Hata olmasi durumunda daha rahat takib edilebilir. 
herstellung von ssh-key-pairs

```bash
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@192.168.178.115
```
Avoiding sudo password prompts in Ansible, open the sudoers file safely:

```bash
sudo visudo
# sudo for the user ansible write
ansible ALL=(ALL) NOPASSWD: ALL
```

(Optional) If you only want to allow passwordless sudo for the reboot command:
```bash
ansible ALL=(ALL) NOPASSWD: /sbin/reboot
```

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
burada özel olarak copy modülü veriliyor detaylar ve örneklerle borlikte 
ansible-doc -t callback -l

# INTRODUCTION

ansible all --list-hosts -i inventory/main.yml
ansible all -m ping -i inventory/main.yaml

The play recap summarizes the results of all tasks in the playbook per host: in our case, for localhost.
`ok=3` indicates that each task ran successfully
In this example there are three tasks (Gathering Facts, Ping my hosts, and Print message)
`changed=0` means we did not edit any preexisting files
`unreachable` informs us if any of our tasks received an error
failed indicates if Ansible is unable to perform the task
`skipped` would tell us if a task was not executed because it didn’t need to be performed
For example, if a task installs nginx but it’s already installed on the host, Ansible will skip the task
`rescued=0` indicates that no rescue command was performed
We can add a “rescue” block of code to a task so that if the command returns false, the task will execute the second block of code rather than fail
`ignored` refers to tasks that are told to ignore_errors
Ansible will cease to execute subsequent tasks if a play fails; in this situation,
`ignore_errors = yes` will force Ansible to continue executing tasks

## SHELL de komut calistirma

```yaml

---
- name: Create file example
  hosts: localhost
  tasks:
    - name: Create/Remove a file with shell module
      ansible.builtin.shell: "touch /tmp/deneme.txt" "remove /tmp/deneme.txt"
```

## IGNORE errors
`ignore_errors`: Bir görev hata verse bile playbook’un diğer görevleri çalıştırmaya devam etmesini sağlar.

```yaml
# IGNORE FAILED COMMANDS
- name: Does not count as failure
  ansible.builtin.command: /bin/false
  ignore_errors: true
```
`ignore_unreachable`: Bir hosta bağlantı kaybolsa bile playbook’un kalan hostlar üzerinde çalışmaya devam etmesini sağlar.
```yaml
# IGNORE UNREACHABLE HOSTS
- name: This task executes, fails, ignores failure
  ansible.builtin.command: /bin/true
  ignore_unreachable: true
```
## Code Quality
Ansible Lint 
ansible-lint test.yaml  korrigieren das .yaml Dokument

## BLOCK ve  RESCUE

block ve rescue Ansible’da hata yönetimi için kullanılır.
block: İçinde bir veya birden fazla görev (task) barındıran, birlikte çalıştırılacak görev bloğudur.
rescue: Eğer block içindeki herhangi bir görev hata verirse çalıştırılan alternatif görev bloğudur.

```yaml
- hosts: localhost
  tasks:
    - block:
        - name: Hata verebilecek görev
          ansible.builtin.shell: "exit 1" 
# exit 0 basarili baska sayi olsa basarisiz demek
        - name: Bu görev sadece block başarılı olursa çalışır
          ansible.builtin.debug:
            msg: "Block başarılı"

      rescue:
        - name: Hata durumunda çalışacak görev
          ansible.builtin.debug:
            msg: "Block içinde hata oluştu"
```
exit 1 çalışırsa, rescue bloğu devreye girer ve hata mesajı yazdırılır. Eğer hata olmazsa rescue çalışmaz.

# AUTOMATION
## FILE MANAGEMENT
create a file
```yaml
- hosts: localhost
  tasks:
  - name: Create test file
    ansible.builtin.file:
      path: /path/remote_node/test_file
      state: touch # absent  yazarsan dosyayi kaldirirsin
```

create a directory
```yaml
- hosts: localhost
  tasks:
  - name: Create Test directory
    ansible.builtin.file:
      path: /home/codio/workspace/test/directory
      recurse: true
      state: directory
```
Create link
```yaml
  - name: Create Test Link
    ansible.builtin.file:
      src: /path/test
      dest: /path/test_link
      state: link
```
copy a file
```yaml
    - name: Copy index.html to the dest folder
      ansible.builtin.copy:
        src: sourse_path/index.html
        dest: /destinetion_path/index.html
```
```yaml
    - name: Copy index.html to the dest folder
      ansible.builtin.copy:
        content: "<h1> Hello, World</h1>"
        dest: /destination_path/index.html
 # uzakta dosya olusturup icine content ekledi       
```
## Replace a String  in a File
```yaml
- name: Replace a string in a file
  ansible.builtin.replace:
    path: /path/to/file.txt
    regexp: 'old_string'
    replace: 'new_string'
```

## HANDLERS
After a file has changed we sometimes need to restart/reload a service. However, if we are running multiple tasks we likely need to avoid a restart on every update made. Handlers are used to manage these situations by differentiating between services that need to be restarted, and performing the restart at the appropriate time. 'Ansible has a built-in notify mechanism to execute handlers so that they only run if notified.' 
Defined separately from tasks, handlers execute only after all tasks have been completed.
Handlers are executed sequentially, in the order they are defined in the handlers section, not in the order listed in the notify statement. Notifying the same handler multiple times will result in executing the handler only once, regardless of how many tasks notify it. For example, if multiple tasks update a configuration file and notify a handler to restart Apache, Ansible only restarts Apache once to avoid unnecessary restarts.
The Notify Keyword
The notify keyword can be applied to a task and accepts a list of handler names that are notified on a task change, as shown in the example below
```yaml
tasks:
  - name: Write the apache config file
      ansible.builtin.copy:
        src: /srv/httpd.j2
        dest: /etc/httpd.conf
      notify:
      - Restart apache

handlers:
  - name: Restart apache
    ansible.builtin.service:
      name: httpd
      state: restarted
```

The above code block is part of a playbook that includes a task to copy an Apache configuration file and a handler to restart the Apache service if the configuration file changes.
The task “Write the apache config file” uses the “copy” module to copy the source file /srv/httpd.j2 to the destination /etc/httpd.conf. The notify keyword is used to trigger the handler Restart apache when this task completes.
The handler, defined separately in the playbook, uses the service module to manage the Apache service. It specifies the name of the service as httpd and sets its state to restarted, ** which will restart the service if it is running or start it if it is not.**

# PACKAGE MANAGEMENT
## Privilege Escalation
To execute many tasks, such as creating configuration files in the /etc folder, we need root user privileges. If an ansible process is running from a normal user, the user should have sudo privilege escalation rights. In order to “become” a user with the required privileges for a task or playbook, the become keyword is used.

### The Become Directives
The directive become: true activates privileges escalation. It can be defined on the level of playbook:
```yaml
- hosts: localhost
  become: true
```
or task level:
```yaml
tasks:
  - name: Ensure the httpd service is running
    service:
      name: httpd
      state: started
    become: true
```
There are two other become directives you should be familiar with:
`become_user`   - set to the user with desired privileges. 
`become_method` - specifies a method and overrides the ansible.cfg default method

```yaml
 tasks:
  - name: Ensure the httpd service is running
    service:
      name: httpd
      state: started
    become: true
    become_user: root
```
## PLAYBOOK UNIVERSALITY

```yaml
- hosts: all
  become: true
  tasks:
    - name: ensure Ubuntu apache2 is at the latest version
        ansible.builtin.apt: 
        name: apache2
        state: present
      when: ansible_distribution == 'Ubuntu'

    - name: ensure RH apache2 is at the latest version
        ansible.builtin.yum: 
        name: apache2
        state: present    
      when: ansible_distribution == 'CentOS' or ansible_distribution == 'RedHat'            
```

## The Systemd Module

Most modern Linux distributions use systemd as their service manager. The `ansible.builtin.systemd` module is used to restart, reload, stop, and/or update systemd services.
```yaml
- name: Make sure a service unit is running
  ansible.builtin.systemd:
    state: started # stop restart reload
    name: httpd
```
state reloaded will bounce the unit.
It is recommended that restarted and reloaded be used in conjunction with handlers to avoid unnecessary restarts.

### The Daemon Reload Parameter
By default, systemd ignores changes to unit (.service) files. If a change has been made to a unit file, such as a change on the command line or changes to environment variables, the parameter daemon_reload: yes must be used to reload systemd with the updated file.
Parameter execution order is critical here, so if daemon_reload is used with a handler, pay attention to handlers’ execution order; reload should come before restart. Otherwise, systemd will pick up the old unit file.
For new files…
If a new unit file is created, reload is not needed; the file will be picked up automatically.
To specify the behavior of a service on restart of a unit, use the enabled parameter:
`enabled: true` to enable (start)
`enabled: false` to disable (stop)
Systemd can start disabled units by means of dependencies or socket activation. To stop the unit from starting it can be masked using masked: yes.

# DÜZENLENECEK KISIM
```yaml
- name: Copy the Grok Exporter systemd service file
    ansible.builtin.copy:
      content: |-
        [Unit]
        Description=Grok Exporter
        After=network.target

        [Service]
        Type=simple
        User=root
        Group=root
        Nice=-5
        ExecStart=/etc/grok_exporter/grok_exporter -config /etc/grok_exporter/grok_exporter.conf

        SyslogIdentifier="grok_exporter"
        Restart=always
        StartLimitBurst=1000

        [Install]
        WantedBy=multi-user.target
      dest: /etc/systemd/system/grok.service
      owner: root
      group: root
      mode: 0644
- name: ensure Grok started
  ansible.builtin.systemd:
    name: grok
    enabled: yes
    started: yes
    daemon_reload: yes
```
The anatomy of the Grok Exporter playbook:
The first task, Copy the Grok Exporter systemd service file, uses the copy module contains several parts:
The [Unit] section includes a description, the defined order, and ensures network connection (internet is required, so this check occurs prior to collecting metrics)
The [Service] section includes:
Type can specified for if the service forks, or in this case just to run it and monitor its state
the User and Group from which we are running it
Nice specifies the priority
ExecStart includes the command, in this case the Grok Exporter (the binary) that the system should start
Restart:always means if this binary crashes it will be restarted
StartLimitBurst specifies a number for which, if exceeded, it will fail
The [Install] section includes the following parameters:
dest, the destination, of the package. It’s important to note that all user managed services and system-level packages should be located in /etc/systemd/system directory.
owner and group
mode: 0644 to specify that the owner can read and write, users within the owner’s group can read, and all users can read.
The second task in the playbook contains:
the name of the service, in this case grok
enabled: yes ensures it starts by default
started: yes indicates we want it started now
daemon_reload: yes means we’ve created the file, so reload and update
The playbook above exemplifies that we can configure all the services we need by using the simple copy (or template) of the service file.
Override Default Parameters
Let’s imagine we’re using Apache2 software and we want to add an additional flag and/or environment variable to the service.
Instead of editing package units in /usr/lib/systemd/system/, which might be overridden by a package update, it is recommended to override starting parameters from package default by creating an override file. We create a directory related to the systemd file we want to change, create the override configuration file, and use the copy module to override parameters configuration as needed.
We need to ensure the directory for override exists and create the file there:

```yaml
- hosts: localhost
  become: true
  tasks:
    - name: Ensure override httpd exists
        ansible.builtin.file:
          path: /etc/systemd/system/httpd.service.d
          state: directory
          owner: root
          group: root
    - name: Create override for httpd envirnoments
        ansible.builtin.copy:
          content: |-
            Environment=LD_LIBRARY_PATH=/opt/vendor/lib
          dest: /etc/systemd/system/httpd.service.d/libraries.conf
          owner: root
          group: root
          mode: 0644
        notify: 
          - Restart httpd
    - name: ensure httpd started
      ansible.builtin.systemd:
        name: httpd
        enabled: yes
        started: yes
        daemon_reload: yes
  handlers:
    - name: Restart httpd
      ansible.builtin.systemd:
        name: httpd
        restarted: yes
        daemon_reload: yes
```
