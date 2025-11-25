
# Project 5 — MySQL Docker Container with Static IP, Custom Network & Persistent Volumes

This project demonstrates how to run a production-style **MySQL container** using:

- User-defined bridge network (`mysql-net`)
- Static container IP (`172.25.0.10`)
- Mounted configuration volume → `/etc/mysql`
- Persistent data volume → `/var/lib/mysql`
- Environment variables for DB initialization
- Host port publishing
- Connecting from another machine using MySQL client

---

## 📁 Project Structure

```
mysql-docker-standalone/
├── volumes/
│   ├── mysql-config/
│   └── mysql-data/
├── network/
│   └── create-network.sh
└── README.md
```

---

## 🔧 Step 1 — Create a Custom Bridge Network

```bash
docker network create \
  --driver bridge \
  --subnet=172.25.0.0/24 \
  mysql-net
```

This ensures stable IP assignment inside Docker.

---

## 📦 Step 2 — Create Volumes

```bash
mkdir -p volumes/mysql-config
mkdir -p volumes/mysql-data
```

---

## 🐬 Step 3 — Run MySQL Container

```bash
docker run -d \
  --name mysql-db \
  --network mysql-net \
  --ip 172.25.0.10 \
  -p 33060:3306 \
  -v $(pwd)/volumes/mysql-config:/etc/mysql \
  -v $(pwd)/volumes/mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=MyRootPass123 \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=AppUserPass123 \
  mysql:8.0
```

### Environment variables:
- `MYSQL_ROOT_PASSWORD` → required  
- `MYSQL_DATABASE` → auto-creates a DB  
- `MYSQL_USER` + `MYSQL_PASSWORD` → creates an additional app user  

---

## 🧪 Step 4 — Check Container Health

```bash
docker ps
docker logs mysql-db
```

---

## 🌐 Step 5 — Connect from Another Node

```bash
mysql -h <docker-host-ip> -P 33060 -u root -p
```

or directly to static container IP (if local LAN):

```bash
mysql -h 172.25.0.10 -u root -p
```

---

## 🛡 Notes

- `172.25.0.10` must be inside the Docker network subnet.  
- Volumes ensure persistence even if the container is removed.  
- The `mysql:8.0` image automatically initializes DB files.  
- Works well with Docker Swarm, Kubernetes migration, and replica setups.

---

## 👤 Author
Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

