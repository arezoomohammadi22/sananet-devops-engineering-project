
# Project 7 — WordPress Stack with Docker Compose (MySQL + phpMyAdmin + Healthchecks)

This project demonstrates how to deploy a **multi-service WordPress stack** using **Docker Compose**, including:

- WordPress (PHP + Apache)
- MySQL 8.0
- phpMyAdmin
- User-defined Docker network
- Persistent volumes for DB & WP data
- Full healthchecks
- Environment variables via `.env`

---

## 📁 Project Structure

```
wordpress-multi-service-compose/
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## 🔧 Step 1 — Prepare Environment Variables

Copy the example:

```bash
cp .env.example .env
```

Edit `.env`:

```
MYSQL_ROOT_PASSWORD=MyRootPass123
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=WpUserPass123

WORDPRESS_TABLE_PREFIX=wp_

PHPMYADMIN_PORT=8081
WORDPRESS_PORT=8080
```

---

## 🐳 Step 2 — docker-compose.yml

```yaml
version: "3.9"

services:
  db:
    image: mysql:8.0
    container_name: wp-mysql
    restart: always
    env_file:
      - .env
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -p${MYSQL_ROOT_PASSWORD} || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - wpnet

  wordpress:
    image: wordpress:php8.2-apache
    container_name: wp-app
    depends_on:
      db:
        condition: service_healthy
    restart: always
    env_file:
      - .env
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      WORDPRESS_TABLE_PREFIX: ${WORDPRESS_TABLE_PREFIX}
    ports:
      - "${WORDPRESS_PORT:-8080}:80"
    volumes:
      - wp_data:/var/www/html
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost/wp-login.php || exit 1"]
      interval: 20s
      timeout: 5s
      retries: 5
    networks:
      - wpnet

  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: wp-phpmyadmin
    depends_on:
      db:
        condition: service_healthy
    restart: always
    env_file:
      - .env
    environment:
      PMA_HOST: db
      PMA_USER: ${MYSQL_USER}
      PMA_PASSWORD: ${MYSQL_PASSWORD}
      UPLOAD_LIMIT: 64M
    ports:
      - "${PHPMYADMIN_PORT:-8081}:80"
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
      interval: 20s
      timeout: 5s
      retries: 5
    networks:
      - wpnet

volumes:
  db_data:
  wp_data:

networks:
  wpnet:
    driver: bridge
```

---

## 🚀 Step 3 — Start the Stack

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

---

## 🌐 Step 4 — Access Services

### WordPress
```
http://localhost:8080/
```

### phpMyAdmin
```
http://localhost:8081/
```

---

## 🧪 Health Checks

```bash
docker inspect --format='{{json .State.Health}}' wp-mysql
docker inspect --format='{{json .State.Health}}' wp-app
docker inspect --format='{{json .State.Health}}' wp-phpmyadmin
```

---

## 🧹 Cleanup

```bash
docker compose down
```

To remove volumes:

```bash
docker compose down -v
```

---

## 👤 Author

Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

