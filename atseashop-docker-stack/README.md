
# AtSea Shop Sample App (Docker Stack)

This project integrates the official **AtSea Shop** microservices application from Docker:

👉 Original repo: https://github.com/dockersamples/atsea-sample-shop-app

The purpose of this project in the DevOps course is to help students practice:

- Deploying a real multi-service production-style application
- Working with **Docker Compose** and **Docker Swarm**
- Managing multiple containers (frontend, backend, payment, database)
- Understanding service dependencies, networks, volumes & secrets

---

## 📁 Project Structure (Course Version)

```
atseashop/
├── README.md
└── (the full upstream repo is cloned separately)
```

This README documents how to run & study the upstream project inside your DevOps lab.

---

## 🔧 1) Clone the Official AtSea Repo

```bash
git clone https://github.com/dockersamples/atsea-sample-shop-app.git
cd atsea-sample-shop-app
```

---

## 🐳 2) Run with Docker Compose (Development Mode)

Inside the cloned repository:

```bash
docker compose up -d
```

Check running services:

```bash
docker compose ps
```

Bring it down:

```bash
docker compose down
```

This is ideal for **local development** and exploring the folder structure.

---

## 🐳 3) Deploy Using Docker Stack (Swarm Mode)

Initialize Swarm (only once):

```bash
docker swarm init
```

Deploy the stack:

```bash
docker stack deploy -c docker-stack.yml atsea
```

Check stack:

```bash
docker stack services atsea
docker stack ps atsea
```

Remove the stack:

```bash
docker stack rm atsea
```

---

## 🌐 4) Access the Application

Typically runs on:

```
http://<docker-host-ip>:8080/
```

or sometimes port 80 depending on the Compose/Stack version.

Check the upstream repo for exact exposed ports.

---

## 🎯 Skills You Learn in This Project

- Deploying **complex multi-container applications**
- Working with:
  - frontend containers
  - backend containers
  - secure payment microservice
  - database initialization
  - secrets & environment variables
  - multiple overlay networks
- Running the same application in:
  - Docker Compose
  - Docker Swarm Stack
- Debugging multi-container failures

This is the first true *microservices application* in the course and represents a real-world e-commerce backend architecture.

---

## 📚 Student Tasks

As part of this DevOps course project, students should:

1. Clone and launch the application via Docker Compose.
2. Deploy the application as a Docker Swarm stack.
3. Draw an **architecture diagram** showing all services and how they connect.
4. Explore logs of each service & document service responsibilities.
5. Set up basic monitoring/log shipping (e.g., Filebeat → Kafka/Elasticsearch).
6. Document their findings in their own README.

---

## 👤 Author (Course Integration Layer)

This README is written to integrate the official AtSea Shop project into:

**Arezoo Mohammadi’s DevOps Engineering Course**  
https://sananetco.com

(Original project maintained by Docker Inc.)


