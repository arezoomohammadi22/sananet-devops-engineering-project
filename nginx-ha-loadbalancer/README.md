
# High-Available Nginx Load Balancer with Keepalived

This project demonstrates how to build a **highly available (HA) Nginx load balancer** using **Keepalived (VRRP)** and a **floating virtual IP (VIP)** shared between two Linux nodes.

- 2 × Load Balancer nodes (Nginx + Keepalived)
- 1 × Virtual IP: `172.20.10.5`
- 3 × Backend application servers behind Nginx

When the primary load balancer fails, Keepalived automatically moves the VIP to the backup node and traffic continues without interruption.

---

## 📁 Project Structure

```
nginx-ha-loadbalancer/
├── keepalived/
│   ├── keepalived-master.conf
│   ├── keepalived-backup.conf
│   └── chk_nginx.sh
├── nginx/
│   └── nginx.conf
└── README.md
```

---

## 🧩 Components

### 1) Nginx
Acts as a **Layer 7 load balancer**, distributing traffic across 3 backend servers:

- 10.0.0.11:80  
- 10.0.0.12:80  
- 10.0.0.13:80  

### 2) Keepalived
Implements **VRRP** to provide a **floating virtual IP** that always points to the active load balancer node.

- VIP: `172.20.10.5`
- MASTER priority: `100`
- BACKUP priority: `50`

---

## 🚀 How to Use

### 1️⃣ Install packages on both load balancers

```bash
sudo apt update
sudo apt install -y nginx keepalived
```

### 2️⃣ Copy the configuration files

On **MASTER node**:

- `/etc/nginx/nginx.conf` ← `nginx/nginx.conf`
- `/etc/keepalived/keepalived.conf` ← `keepalived/keepalived-master.conf`
- `/etc/keepalived/chk_nginx.sh` ← `keepalived/chk_nginx.sh`

On **BACKUP node**:

- `/etc/nginx/nginx.conf` ← `nginx/nginx.conf`
- `/etc/keepalived/keepalived.conf` ← `keepalived/keepalived-backup.conf`
- `/etc/keepalived/chk_nginx.sh` ← `keepalived/chk_nginx.sh`

Make the health-check script executable:

```bash
sudo chmod +x /etc/keepalived/chk_nginx.sh
```

### 3️⃣ Enable and start services

On **both** nodes:

```bash
sudo systemctl enable nginx keepalived
sudo systemctl restart nginx keepalived
```

---

## ✅ Verification

### Check which node owns the VIP:

```bash
ip addr show enp0s3 | grep 172.20.10.5
```

### From a client, hit the VIP:

```bash
curl http://172.20.10.5
```

### Failover test:

```bash
sudo systemctl stop nginx
```

Check again:

```bash
ip addr show enp0s3 | grep 172.20.10.5
```

---

## 🛡 Notes

- Replace `enp0s3` with your actual network interface name.
- Replace backend IPs (`10.0.0.11/12/13`) with your real app servers.
- The same Nginx config is used on both LB nodes – Keepalived decides who is active.
- This project reflects real production scenarios in a simplified form.

---

## 👤 Author

Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

