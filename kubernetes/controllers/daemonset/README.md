# Node Exporter DaemonSet on Kubernetes

This lab demonstrates how to deploy **Prometheus Node Exporter** as a **DaemonSet** on Kubernetes in order to collect node-level metrics (CPU, memory, disks, filesystems, etc.) from **every node** in the cluster.

By using a DaemonSet, Kubernetes automatically ensures that a `node-exporter` Pod is running on **each node**, and that it is re-created when nodes are added or removed.

---

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- Understand when and why to use a **DaemonSet** instead of a Deployment
- Deploy **Prometheus Node Exporter** as a DaemonSet on all nodes
- Use **host mounts**, `hostNetwork`, and `hostPID` to expose node-level metrics
- Prepare your cluster so Prometheus (or another monitoring system) can scrape node metrics

---

## 🗂 Project Structure

A simple structure for this project:

```text
node-exporter-daemonset/
└── k8s
    └── node-exporter-daemonset.yaml
```

- **k8s/node-exporter-daemonset.yaml** – Contains the DaemonSet manifest for Node Exporter (and optionally the `monitoring` namespace if needed).

---

## ☸️ Kubernetes Manifest

Save the following YAML as `k8s/node-exporter-daemonset.yaml`:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          args:
            - "--path.rootfs=/host"
          ports:
            - containerPort: 9100
              hostPort: 9100
              protocol: TCP
          volumeMounts:
            - name: rootfs
              mountPath: /host
              readOnly: true
      volumes:
        - name: rootfs
          hostPath:
            path: /
```

> ℹ️ **Notes:**
>
> - `hostNetwork: true` allows the Pod to use the node's network namespace and exposes Node Exporter directly on the node's IP on port `9100`.
> - `hostPID: true` allows visibility into host processes if Node Exporter needs it.
> - The `hostPath` mount (`/` → `/host`) combined with `--path.rootfs=/host` lets Node Exporter read host filesystem metrics from the underlying node.

You may need to create the `monitoring` namespace if it does not already exist:

```bash
kubectl create namespace monitoring
```

---

## ✅ Prerequisites

To complete this lab, you should have:

- A running Kubernetes cluster (Kind, Minikube, k3s, or a production cluster)
- `kubectl` configured to talk to your cluster
- Permissions to create resources in the `monitoring` namespace
- Optional but recommended: a Prometheus instance in your cluster to scrape metrics from Node Exporter

---

## 🚀 1. Deploy Node Exporter DaemonSet

Apply the manifest:

```bash
kubectl apply -f k8s/node-exporter-daemonset.yaml
```

Then verify that the DaemonSet and Pods are running:

```bash
kubectl get daemonsets -n monitoring
kubectl get pods -n monitoring -l app=node-exporter -o wide
```

You should see one `node-exporter` Pod per node (for example, one per worker node).

---

## 🌐 2. Verify Metrics Endpoint

Because `hostNetwork: true` and `hostPort: 9100` are used, Node Exporter will expose metrics on **each node IP** at port `9100`.

You can test this in different ways:

### Option A: Curl from inside the cluster

Create a temporary Pod and use `curl`:

```bash
kubectl run -it curl --rm --image=curlimages/curl --restart=Never --   curl http://<node-ip>:9100/metrics
```

Replace `<node-ip>` with the IP address of one of your nodes.

### Option B: Curl from outside (lab environment only)

If you have direct network access to your nodes from your machine, you can run:

```bash
curl http://<node-ip>:9100/metrics
```

You should see Prometheus-compatible metrics text output.

---

## 📡 3. Integrate with Prometheus (Conceptual)

To actually scrape these metrics, your Prometheus configuration should include a scrape job similar to:

```yaml
scrape_configs:
  - job_name: 'node-exporter'
    static_configs:
      - targets:
        - '<node1-ip>:9100'
        - '<node2-ip>:9100'
        # ...
```

In production clusters, you would typically use Kubernetes service discovery rather than static IPs, but for the purpose of this lab it's enough to understand that Prometheus scrapes the `/metrics` endpoint on port `9100` of each node.

---

## 🧪 4. Explore DaemonSet Behavior

You can experiment with DaemonSet behaviour:

- **Add a node** to your cluster (if possible) and observe that a new `node-exporter` Pod is automatically scheduled on it.
- **Cordon/uncordon** a node and see how the DaemonSet reacts.
- **Delete** one of the Pods manually:

  ```bash
  kubectl delete pod <pod-name> -n monitoring
  ```

  Kubernetes will automatically recreate the Pod on the same node.

---

## 🧹 5. Cleanup

To remove the Node Exporter DaemonSet:

```bash
kubectl delete -f k8s/node-exporter-daemonset.yaml
```

If you created a dedicated `monitoring` namespace just for this lab and it is no longer needed, you can delete it (be careful not to delete it if you have other monitoring components there):

```bash
kubectl delete namespace monitoring
```

---

## 📚 Summary

In this lab you:

- Deployed **Prometheus Node Exporter** as a **DaemonSet** running on all nodes
- Used `hostNetwork`, `hostPID`, and a `hostPath` mount to expose node-level metrics
- Verified that metrics are available on `http://<node-ip>:9100/metrics`
- Learned how DaemonSets are ideal for node-level agents (monitoring, logging, security, etc.)

This pattern is widely used for running cluster-wide agents such as:

- Node-level monitoring (Node Exporter)
- Log collectors (Fluentd, Filebeat, etc.)
- Security agents and node-level sidecars

You can build on this lab by adding a full Prometheus + Grafana stack and visualizing node metrics in dashboards.
