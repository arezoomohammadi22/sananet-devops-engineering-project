
# Project 6 — Flask + Redis with Docker Compose (Build From Dockerfile + Healthchecks)

This project demonstrates how to deploy a **Flask Python application** that depends on **Redis** using **Docker Compose**.

It includes:

- A Flask app container built from a custom **Dockerfile**
- A Redis container
- A user-defined network
- Health checks for both services
- Redis used as a simple key-value store

---

## 📁 Project Structure

```
flask-redis-compose/
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
├── docker-compose.yml
└── README.md
```

---

## 🧩 Flask Application (`app.py`)

```python
from flask import Flask
import redis
import os

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = int(os.getenv("REDIS_PORT", "6379"))

r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route("/")
def index():
    r.incr("hits")
    return f"Hello from Flask! Redis counter = {r.get('hits')}"

@app.route("/healthz")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## 📦 Dockerfile for Flask

`app/Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

## 📜 requirements.txt

```
flask
redis
```

---

## 🐳 docker-compose.yml

```yaml
version: "3.9"

services:
  web:
    build: ./app
    container_name: flask-app
    ports:
      - "5000:5000"
    environment:
      REDIS_HOST: redis
      REDIS_PORT: 6379
    depends_on:
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/healthz"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - flasknet

  redis:
    image: redis:7
    container_name: redis-db
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    networks:
      - flasknet

volumes:
  redis-data:

networks:
  flasknet:
    driver: bridge
```

---

## 🚀 Run the Stack

From the project root:

```bash
docker compose up -d --build
```

Check running services:

```bash
docker compose ps
```

---

## 🌐 Test the Application

Open in browser:

```
http://localhost:5000/
```

Or:

```bash
curl http://localhost:5000/
```

Expected output:

```
Hello from Flask! Redis counter = 1
```

Reload page and counter increases.

---

## 🧪 Test Health Checks

```bash
docker inspect --format='{{json .State.Health}}' flask-app
docker inspect --format='{{json .State.Health}}' redis-db
```

---

## 🧹 Stop the Stack

```bash
docker compose down
```

---

## 👤 Author

Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

