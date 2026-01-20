Zero-Trust Virtual Data Center

This project demonstrates the architecture and deployment of a hardened, enterprise-grade virtual data center built on KVM/QEMU. It focuses on the **Zero-Trust** security model, centralized identity management, automated configuration, and proactive monitoring.

```text
├── README.md               # Main summary, diagrams, and quick look
├── Documentation/          # Detailed PDF and additional documents
│   └── Project_Report.pdf
├── Infrastructure/         # Ansible playbooks or configurations
├── Diagrams/               # Original Mermaid or Draw.io files
└── Screenshots/            # Images used inside the README
```

# 🎯 Project Objectives
- **Security Hardening:** Implementing multi-layer defense mechanisms (IDS/IPS, Firewalls, ACLs).
- **Identity & Access Management (IAM):** Centralized authentication and granular authorization (RBAC/HBAC).
- **Observability:** Centralized logging and real-time monitoring for incident response.
- **Infrastructure as Code (IaC):** Automated deployment and configuration management.

---

# 🛠 Tech Stack
- **Virtualization:** KVM/QEMU, Libvirt, Virt-Manager (on Rocky Linux Host)
- **Identity:** FreeIPA (LDAP, Kerberos, DNS, PKI)
- **Security:** pfSense/OPNsense, Suricata (IDS/IPS), Nginx (Reverse Proxy)
- **Monitoring & Logging:** Prometheus, Grafana, ELK Stack or Graylog
- **Automation & DevSecOps:** Ansible, Podman (Rootless Containers), Gitea (GitOps)
- **Backup:** BorgBackup / Restic

---

**Infrastructure Roadmap**


# Layer 1: Virtualization & Network Foundation

## Layer 1A: Host System (Rocky Linux) 
### System Update & Essential Virtualization Packages
```bash 
# System update and installation of core virtualization components:

  sudo dnf update -y
  sudo dnf install -y qemu-kvm libvirt virt-install
```
---

### Virtualization Capability & Hypervisor Validation
```bash
# CPU virtualization support verification:

  lscpu | grep Virtualization

# KVM kernel module verification:

  lsmod | grep kvm

# Libvirt and host virtualization validation:

  sudo virt-host-validate
```
---

### Libvirt Service Enablement
```bash
# Enable and start libvirt daemon:
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd
```
---

### Host-Level Security Hardening
```bash
# SELinux status verification and enforcement:
getenforce
sudo setenforce 1

# Or set SELINUX=enforcing in SELnux configuration file (/etc/selinux/config):
```

```yaml 
# Edit SSH daemon configuration file (/etc/ssh/sshd_config):
PermitRootLogin no
PasswordAuthentication no
```
```nash
sudo systemctl restart sshd # Apply configuration changes
```
---

### User Permissions & Libvirt Access Control

```bash
  sudo usermod -aG libvirt $(whoami) # Add current user to libvirt group. Re-login required

  virsh list --all # Libvirt access verification:
  Id   Name   State      # Expected output format:
  --------------------
```
---



- **[1-B] Network Segmentation:** Isolation of MGMT, LAN, and DMZ zones.


## Layer 1B: Revised Network Segmentation Plan

| Network Zone  | Subnet       | Purpose                                  | Security Policy                                |
|---------------|--------------|-------------------------------------------|-----------------------------------------------|
| MGMT          | 10.0.10.0/24 | Core Infrastructure (FreeIPA, DNS, DHCP, Ansible )  | Restricted: Only Admin access allowed         |
| LAN (Corp)    | 10.0.20.0/24 | Corporate Workstations (Fedora / Ubuntu)  | Internal: Authorized employees only           |
| DMZ (Frontend)| 10.0.30.0/24 | Customer Web Apps & Reverse Proxies       | Untrusted: Exposed to public traffic          |
| APP (K8s/Prod)| 10.0.40.0/24 | Application Logic & K8s Nodes             | Scalable: High-demand customer workloads      |
| DB (Backend)  | 10.0.50.0/24 | Databases (MariaDB / PostgreSQL)          | Critical: No direct internet access           |
| SEC (Ops)     | 10.0.60.0/24 | IDS/IPS & Logging & Monitoring & Visualization (Suricata / ELK / Prometheus / Grafana)     | Security: Log collection & traffic analysis   |
| GUEST         | 10.0.70.0/24 | Unauthenticated Visitor Access            | Isolated: Internet-only access                |

---



## Layer 1C : Topology Design: 
Default rule: **DENY ALL – ALLOW explicitly per service, port, and direction**.

### Logical Zone Trust Model

| Zone  | Trust Model |
|------|-------------|
| MGMT | Control-plane, restricted service exposure |
| LAN  | Authenticated users |
| DMZ  | Untrusted |
| APP  | Semi-trusted |
| DB   | Highly restricted |
| SEC  | Observability-only |
| GUEST| Untrusted |

---

### Zone-to-Zone Access Matrix (Logical)

#### Infrastructure Services (MGMT as Provider)

| Source Zone   | Destination | Service  |    Protocol / Port     |   
|---------------|-------------|----------|-------------------------|
| ALL Zones     | MGMT        | DHCP     |      UDP 67/68           |
| ALL Zones     | MGMT        | DNS      |      TCP/UDP 53          |
| LAN, APP, SEC | MGMT        | FreeIPA  | TCP/UDP 389, 636, 88, 464 |
| MGMT          | ANY         | —        |          DENY             |

---

#### Application and Data Flow

| Source | Destination   |          Service           |
|--------|---------------|----------------------------|
|   LAN  |    DMZ         |      HTTP / HTTPS          |
|   DMZ  |    APP         | Application-specific ports |
|   APP  |    DB          |      Database ports only    |
|   ANY  |    DB (direct) |            DENY             |

---

#### Security and Observability

| Source   | Destination |        Service          |
|----------|-------------|------------------------- |
|    SEC   |     ALL     | Metrics / Log collection  |
|    ALL   |      SEC    |         Log shipping      |

---

#### Guest Isolation

| Source | Destination   | Policy |
|--------|---------------|--------|
| GUEST |    Internet    |  ALLOW |
| GUEST | Internal Zones |  DENY  |

---

#### Explicit Zero-Trust Deny Rules

- ANY → MGMT : DENY  
  - Exceptions: DNS, DHCP, FreeIPA only
- ANY → DB : DENY
- DMZ → MGMT : DENY  
  - Exception: DNS only

---



### PAU++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++SE 






# Layer 2: Core Infrastructure Services
- **[2-A] DNS & DHCP:** Internal name resolution (Bind9) and dynamic addressing (Kea DHCP).
- **[2-B] Time Sync:** NTP strategy for log consistency across the domain.

# Layer 3: Identity & Access Management (IAM)
- **[3-A] FreeIPA Deployment:** Centralized Auth, Kerberos, and Internal Certificate Authority.
- **[3-B] Access Control:** Implementing HBAC (Host-Based Access Control) and Sudo rules.
- **[3-C] Client Integration:** Joining Fedora Workstations and Ubuntu Servers to the domain.

# Layer 4: Defensive Security & Traffic Management
- **[4-A] Edge Security:** Firewall ACLs, NAT, and inter-VLAN routing policies.
- **[4-B] Network Security:** IDS/IPS (Suricata) implementation for threat detection.
- **[4-C] Secure Entry:** Reverse Proxy with TLS termination and VPN access.

# Layer 5: Observability & Incident Response
- **[5-A] Centralized Logging:** Auditing authentication, sudo, and system logs.
- **[5-B] Health Monitoring:** Real-time metrics and alerting for infrastructure health.
- **[5-C] Service Availability:** Uptime tracking for critical business services.

# Layer 6: Application & Container Services
- **[6-A] Service Tier:** Hardened Web (Nginx) and Database (MariaDB/PostgreSQL) servers.
- **[6-B] Containerization:** Rootless Podman scenarios for microservices.
- **[6-C] Secure Storage:** Encrypted file sharing and data persistence.

# Layer 7: Automation & DevSecOps
- **[7-A] IaC with Ansible:** Automated hardening and configuration playbooks.
- **[7-B] GitOps:** Version control for all configuration files via Gitea.
- **[7-C] Backup & Disaster Recovery:** Snapshot policies and off-site backup simulation.

---
*Last Updated: December 31, 2025*