# Node.js Deployment with HTTP Liveness & Readiness Probes

This lab demonstrates how to run a simple Node.js web application on Kubernetes using a **Deployment** configured with **HTTP liveness and readiness probes**.

The application exposes three HTTP endpoints:

- `/` – returns a simple **Hello World** response  
- `/healthz` – used by the **liveness probe**  
- `/ready` – used by the **readiness probe**

These probes allow Kubernetes to automatically detect when a container is unhealthy or not ready to receive traffic.

---

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- Containerize a Node.js application using a `Dockerfile`
- Configure **liveness** and **readiness** probes in a Kubernetes `Deployment`
- Understand the difference between:
  - Liveness probes (when the container should be restarted)
  - Readiness probes (when the Pod should receive traffic)
- Inspect Pod status and probe results using `kubectl`

---

## 🗂 Project Structure

A recommended structure for this project is:

```text
nodejs-k8s-probes-deployment/
├── app.js
├── package.json
├── Dockerfile
└── k8s
    └── deployment.yaml
```

- **app.js** – Simple Express.js application exposing `/`, `/healthz`, and `/ready`
- **package.json** – Node.js dependencies and start script
- **Dockerfile** – Instructions to build the container image
- **k8s/deployment.yaml** – Kubernetes Deployment manifest with liveness & readiness probes

---

## 📦 Application Code (Node.js / Express)

The Node.js application exposes three routes and listens on port **80**:

```js
const express = require('express');
const app = express();
const port = 80;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.get('/healthz', (req, res) => {
  // You can add custom health check logic here
  res.status(200).send('OK');
});

app.get('/ready', (req, res) => {
  // You can add custom readiness check logic here
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
```

---

## 📁 package.json

```json
{
  "name": "node-k8s-probes",
  "version": "1.0.0",
  "description": "A sample Node.js app with Kubernetes probes",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.17.1"
  }
}
```

---

## 🐳 Dockerfile

```dockerfile
# Use the official Node.js image
FROM node:14

# Create and change to the app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

# Run the web service on container startup
CMD [ "node", "app.js" ]
```

---

## ☸️ Kubernetes Deployment Manifest

Save the following as `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nodejs
  template:
    metadata:
      labels:
        app: nodejs
    spec:
      containers:
      - name: nodejs
        image: your-dockerhub-username/node-k8s-probes:1.0
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /healthz
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
```

> 🔁 **Important:**  
> Replace `your-dockerhub-username` with your own Docker Hub username (or any container registry you use).

---

## ✅ Prerequisites

To run this lab, you need:

- A working Kubernetes cluster (Kind, Minikube, k3s, or any other)
- `kubectl` configured to talk to your cluster
- Docker (or compatible container runtime) installed and logged in to your registry

---

## 🛠 1. Build & Push the Docker Image

From the project root directory (`nodejs-k8s-probes-deployment/`):

```bash
# Build the image
docker build -t your-dockerhub-username/node-k8s-probes:1.0 .

# Push to Docker Hub (or your registry)
docker push your-dockerhub-username/node-k8s-probes:1.0
```

Again, make sure to replace `your-dockerhub-username` with your actual Docker Hub username.

---

## ☸️ 2. Deploy to Kubernetes

Apply the Deployment manifest:

```bash
kubectl apply -f k8s/deployment.yaml
```

Check the status of the Deployment and Pods:

```bash
kubectl get deployments
kubectl get pods -l app=nodejs
```

---

## 🔍 3. Verify Liveness & Readiness Probes

### Check Pod details

Use `kubectl describe` to see probe configuration and status:

```bash
kubectl describe pod <pod-name>
```

Look for the **Liveness** and **Readiness** sections in the output.

### Port-forward to test endpoints

Forward a local port to one of the Pods:

```bash
kubectl port-forward pod/<pod-name> 8080:80
```

Then in another terminal or browser:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
curl http://localhost:8080/ready
```

You should see:

- `/`      → `Hello World!`
- `/healthz` → `OK`
- `/ready`   → `OK`

---

## 🧪 4. Experiment: Simulating Probe Failures (Optional)

To better understand how probes work, try:

1. **Break liveness**  
   - Modify `/healthz` to return a `500` status code or throw an error.
   - Rebuild and push the image, then update the Deployment.
   - Observe Kubernetes restarting the container when the liveness probe fails repeatedly.

2. **Break readiness**  
   - Modify `/ready` to return a `500` or respond slowly.
   - Watch how the Pod is marked **NotReady** and is removed from Service endpoints, but the container is not restarted.

Use:

```bash
kubectl get pods -w
```

to watch status changes live.

---

## 🧹 5. Cleanup

When you are done with the lab, delete the Deployment:

```bash
kubectl delete -f k8s/deployment.yaml
```

If you created a Service or any other resources, delete them as well.

---

## 📚 Summary

This lab showed how to:

- Containerize a simple Node.js application
- Configure **HTTP liveness and readiness probes** in a Kubernetes `Deployment`
- Observe how Kubernetes reacts when an application becomes unhealthy or temporarily not ready

You can extend this lab by:

- Adding a `Service` and testing how readiness affects traffic routing
- Introducing artificial delays or failures in the app to observe different probe behaviours
- Integrating this Deployment with an Ingress or Gateway in more advanced labs
