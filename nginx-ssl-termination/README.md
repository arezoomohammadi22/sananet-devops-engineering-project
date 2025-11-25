
# SSL Termination with Nginx

This project demonstrates how to configure **Nginx** as a reverse proxy with **SSL termination**, using both **Let’s Encrypt (valid certificates)** and **Self‑Signed Certificates**.

---

## 📌 Project Structure
```
.
├── lets-encrypt
│   ├── certbot-renew.sh
│   └── nginx.conf
└── self-signed
    ├── generate-cert.sh
    └── nginx.conf
```

---

## 🚀 Let’s Encrypt (Valid SSL)

### 1) Install Certbot
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

### 2) Generate SSL Certificate
```bash
sudo certbot --nginx -d example.com -d www.example.com
```

### 3) Auto-Renew Setup
Add cronjob:
```
0 3 * * * /path/to/certbot-renew.sh
```

---

## 🔐 Self‑Signed Certificate

### 1) Generate Certificate
```bash
bash generate-cert.sh
```

### 2) Apply to Nginx
Copy the generated cert & key into your server SSL directory and update nginx.conf.

---

## 🛡 Security Practices
- TLS 1.2 / 1.3  
- Strong cipher suites  
- Redirect HTTP → HTTPS  
- HSTS header  
- OCSP stapling ready  

---

## 👤 Author
Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

