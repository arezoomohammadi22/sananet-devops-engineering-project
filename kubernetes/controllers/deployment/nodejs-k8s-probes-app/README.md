# Node.js App with Kubernetes Liveness & Readiness Probes

This project is a simple Node.js web application packaged in a Docker image and deployed to Kubernetes with **exec-based liveness and readiness probes**.

## Endpoints

- `/` – returns `Hello World!`
- `/healthz` – used by the liveness probe
- `/ready` – used by the readiness probe

## Project Structure

```text
.
├── app.js               # Node.js Express app
├── package.json         # Dependencies & metadata
├── Dockerfile           # Image build instructions
├── health-check.sh      # Liveness probe script
├── ready-check.sh       # Readiness probe script
└── k8s-deployment.yaml  # Kubernetes Deployment manifest
```

## Quickstart

### Build & Run Locally

```bash
npm install
npm start
```

### Build & Push Docker Image

```bash
docker build -t your-dockerhub-username/node-k8s-probes:1.0 .
docker push your-dockerhub-username/node-k8s-probes:1.0
```

### Deploy to Kubernetes

```bash
kubectl apply -f k8s-deployment.yaml
kubectl get pods
```
