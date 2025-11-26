# Kubernetes Pod with Init Containers (Dynamic Nginx Page)

This project demonstrates how to use **init containers** in Kubernetes to prepare data for a main application container.  
A pair of BusyBox init containers generate HTML content that includes the Pod's IP address and share it with an Nginx web server through an `emptyDir` volume.

## Learning Objectives

By the end of this lab, the student will be able to:

- Understand the difference between **init containers** and regular containers in a Pod.
- Use the **Kubernetes Downward API** to inject the Pod IP into an environment variable.
- Share data between init containers and the main container using an `emptyDir` volume.
- Expose static content through Nginx that was generated at Pod start-up.
- Inspect Pod logs to verify the behaviour of init containers.

## Repository Structure

```text
.
├── README.md
└── manifests
    └── pod-with-initcontainers.yaml
```

- **README.md** – You are here. Explains the lab and how to run it.
- **manifests/pod-with-initcontainers.yaml** – Pod manifest with init containers and an Nginx web server.

## Prerequisites

- A running Kubernetes cluster (local or remote).
- `kubectl` configured to talk to the cluster.
- Basic familiarity with Pods and containers.

## Manifest Overview

The Pod has three containers:

1. **Init container `write-ip`**
   - Image: `busybox`
   - Reads the Pod IP from the environment variable `MY_POD_IP` (via Downward API).
   - Writes it to `/web-content/ip.txt` inside a shared volume.

2. **Init container `create-html`**
   - Image: `busybox`
   - Creates `/web-content/index.html`.
   - Writes a greeting and appends the IP from `ip.txt`.
   - This file will later be served by Nginx.

3. **Main container `web-container`**
   - Image: `nginx`
   - Serves the files from the shared volume at `/usr/share/nginx/html`.

A single `emptyDir` volume named `web-content` is shared by all containers.

## How to Deploy

1. Clone this repository (or copy the files into your own repo):

```bash
git clone <your-repo-url>.git
cd k8s-pod-init-containers
```

2. Apply the manifest:

```bash
kubectl apply -f manifests/pod-with-initcontainers.yaml
```

3. Check Pod status:

```bash
kubectl get pods
kubectl describe pod web-server-pod
```

You should see the init containers complete successfully before the main Nginx container starts.

## Verify the Init Containers

View the logs of the init containers:

```bash
kubectl logs pod/web-server-pod -c write-ip
kubectl logs pod/web-server-pod -c create-html
```

You should see messages similar to:

- `Wrote the Pod IP to ip.txt`
- `Created index.html with the Pod IP`

To inspect the generated HTML file, you can exec into the Nginx container:

```bash
kubectl exec -it web-server-pod -c web-container -- cat /usr/share/nginx/html/index.html
```

You should see a line like:

```text
Hello, World! Your Pod IP is: 10.244.0.12
```

(Your IP will vary depending on the cluster.)

## Accessing the Web Page

For a simple test, you can port-forward the Pod:

```bash
kubectl port-forward pod/web-server-pod 8080:80
```

Then in your browser (or using `curl`):

```bash
curl http://localhost:8080
```

You should see the HTML page that includes the Pod IP.

## Clean Up

When you are done with the lab, delete the Pod:

```bash
kubectl delete -f manifests/pod-with-initcontainers.yaml
```

## Suggested Exercises for Students

To deepen understanding, ask students to:

1. **Modify the message** in `index.html` to include the Pod name using another environment variable from the Downward API.
2. **Add a second volume** and persist extra data between restarts using a `hostPath` or a real storage class.
3. **Turn this Pod into a Deployment** to see how each replica gets its own IP in the generated page.
4. **Break the init container** on purpose (e.g., wrong path) and observe how the Pod never becomes `Running`.

These exercises help students understand how init containers can be used to prepare configuration, data, or environment for the main application container.
