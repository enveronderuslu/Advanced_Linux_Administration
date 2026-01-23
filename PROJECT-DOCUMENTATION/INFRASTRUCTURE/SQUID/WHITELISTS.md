whitelist_mgmt.txt
```vim
vim /etc/squid/whitelists/whitelist_mgmt.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
download.rockylinux.org
dl.rockylinux.org
vault.rockylinux.org
dl.fedoraproject.org
download.fedoraproject.org/pub/epel
mirrors.fedoraproject.org
.rockylinux.org
.fedoraproject.org
.kernel.org
.isc.org
.ansible.com
.pypi.org
.pythonhosted.org
.launchpadcontent.net
.canonical.com
.cloudflare.com

```

whitelist_corp.txt
```vim
vim /etc/squid/whitelists/whitelist_corp.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
```

whitelist_dmz.txt
```vim
vim /etc/squid/whitelists/whitelist_dmz.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.nginx.org
.haproxy.org
```

whitelist_app.txt
```vim
vim /etc/squid/whitelists/whitelist_app.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.kubernetes.io
.docker.com
.io.containerd
```

whitelist_db.txt
```vim
vim /etc/squid/whitelists/whitelist_db.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.mariadb.org
.postgresql.org
```

whitelist_sec.txt
```vim
vim /etc/squid/whitelists/whitelist_sec.txt
.ubuntu.com
.archive.ubuntu.com
.security.ubuntu.com
.fedoraproject.org
.suricata-ids.org
.elastic.co
.prometheus.io
.grafana.com
```
create  these files wita script

``sh
#!/bin/bash
cat <<'EOF' > /etc/squid/whitelists/deneme1.txt
.ubuntu.com
.archive.ubuntu.com
EOF
cat <<'EOF' > /etc/squid/whitelists/deneme2.txt
.ubuntu.com
.archive.ubuntu.com
EOF
```
