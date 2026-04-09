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