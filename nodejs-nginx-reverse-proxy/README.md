
# Project 4 — Node.js App behind Nginx Reverse Proxy

This project demonstrates how to:

- Run a simple **Node.js (Express)** application on **port 3000**
- Expose it to clients through an **Nginx reverse proxy** on port 80
- Forward client IP & headers correctly
- Provide a `/healthz` endpoint for monitoring

This is one of the most common real-world production patterns.

---

## 📁 Project Structure

```
nodejs-nginx-reverse-proxy/
├── app/
│   ├── package.json
│   └── server.js
├── nginx/
│   └── node-app.conf
└── README.md
```

---

## 🧩 Node.js Application

### 1️⃣ Install dependencies
```bash
cd app
npm install
```

### 2️⃣ Run the app
```bash
npm start
```

The app listens on:
- `http://localhost:3000/`
- `http://localhost:3000/healthz`

### server.js
```js
const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send(\`Hello from Node.js app behind Nginx reverse proxy! 💚
Request came from: \${req.headers["x-forwarded-for"] || req.ip}
Host: \${req.headers["host"]}\`);
});

app.get("/healthz", (req, res) => {
  res.status(200).send("OK");
});

app.listen(PORT, () => {
  console.log(\`Node.js app listening on port \${PORT}\`);
});
```

---

## 🌐 Nginx Reverse Proxy

### 1️⃣ Copy the Nginx config
```bash
sudo cp nginx/node-app.conf /etc/nginx/conf.d/node-app.conf
```

### 2️⃣ Test & reload Nginx
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### node-app.conf
```nginx
upstream node_app {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name example.com;

    access_log /var/log/nginx/node-app-access.log;
    error_log  /var/log/nginx/node-app-error.log;

    location / {
        proxy_pass http://node_app;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /healthz {
        proxy_pass http://node_app/healthz;
    }
}
```

---

## ✅ Verification

### Test Node.js directly:
```bash
curl http://localhost:3000/
curl http://localhost:3000/healthz
```

### Test through Nginx:
```bash
curl http://<server-ip>/
curl http://<server-ip>/healthz
```

---

## 🛡 Notes
- Port 3000 is not exposed to the Internet directly.
- Nginx handles all incoming traffic.
- Can be extended with Projects:
  - SSL (Project 1)
  - HA with Keepalived (Project 2)
  - Logging pipeline with Filebeat (Project 3)

---

## 👤 Author  
Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

