# MySQL StatefulSet on Kubernetes

This lab demonstrates how to deploy **MySQL** on Kubernetes using a **StatefulSet** with persistent storage and a **headless Service** for stable network identities.

Instead of using a simple `Deployment`, a StatefulSet gives each Pod:

- A stable **network identity** (`mysql-0`, `mysql-1`, `mysql-2`, …)
- Its own **PersistentVolumeClaim** (PVC) and data directory
- Predictable ordering and graceful termination

This pattern is common for running stateful workloads such as databases in Kubernetes.

---

## 🎯 Learning Objectives

By the end of this lab, you will be able to:

- Deploy a **MySQL StatefulSet** with multiple replicas
- Use **`volumeClaimTemplates`** to provision persistent storage per replica
- Expose the StatefulSet via a **headless Service** for stable DNS records
- Inspect Pods, PVCs, and volumes created by a StatefulSet

---

## 🗂 Project Structure

A recommended structure for this project is:

```text
mysql-k8s-statefulset/
└── k8s
    └── mysql-statefulset.yaml
```

- **k8s/mysql-statefulset.yaml** – Contains both the `StatefulSet` and the headless `Service` manifests.

You can also separate the StatefulSet and Service into different files if you prefer.

---

## ☸️ Kubernetes Manifests

Save the following content as `k8s/mysql-statefulset.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: mysql
        image: mysql:8
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "rootpassword"
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 5Gi
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
    - port: 3306
  clusterIP: None  # Headless service
  selector:
    app: mysql
```

> ℹ️ **Note:**  
> The `clusterIP: None` field makes this a **headless Service**, which is required for the StatefulSet to create stable DNS entries like `mysql-0.mysql`, `mysql-1.mysql`, etc.

---

## ✅ Prerequisites

To run this lab, you need:

- A running Kubernetes cluster (Kind, Minikube, k3s, or a production cluster)
- `kubectl` installed and configured
- A default **StorageClass** in the cluster (for dynamic PVC provisioning)
- Enough storage capacity to create three PVCs of 5Gi each

You can verify available StorageClasses with:

```bash
kubectl get storageclass
```

---

## 🚀 1. Deploy MySQL StatefulSet

From the project root directory:

```bash
kubectl apply -f k8s/mysql-statefulset.yaml
```

Check the StatefulSet, Pods, and headless Service:

```bash
kubectl get statefulsets
kubectl get pods -l app=mysql
kubectl get svc mysql
```

You should eventually see Pods named:

- `mysql-0`
- `mysql-1`
- `mysql-2`

---

## 📦 2. Inspect Persistent Volume Claims

Each replica will get its own PVC, created automatically from `volumeClaimTemplates`:

```bash
kubectl get pvc
```

You should see something similar to:

```text
NAME                         STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-storage-mysql-0        Bound    ...      5Gi        RWO            ...            ...
mysql-storage-mysql-1        Bound    ...      5Gi        RWO            ...            ...
mysql-storage-mysql-2        Bound    ...      5Gi        RWO            ...            ...
```

Each PVC corresponds to one MySQL Pod and will preserve its data even if the Pod is rescheduled.

---

## 🔗 3. Connect to MySQL

To connect to MySQL running in one of the Pods, you can use `kubectl exec`.

For example, to connect to `mysql-0`:

```bash
kubectl exec -it mysql-0 -- mysql -uroot -p
```

When prompted for the password, enter:

```text
rootpassword
```

You can create a test database and table:

```sql
CREATE DATABASE demo;
USE demo;
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(50));
INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob');
SELECT * FROM users;
```

Exit MySQL and the shell when done:

```sql
EXIT;
```

```bash
exit
```

---

## 🌐 4. Understand DNS & Headless Service

With a headless Service (`clusterIP: None`), each Pod in the StatefulSet gets a stable DNS name:

- `mysql-0.mysql`
- `mysql-1.mysql`
- `mysql-2.mysql`

You can test DNS resolution from inside one of the Pods (if tools like `nslookup` or `dig` are installed, or by using another utility container in the cluster).

These stable identities are what make StatefulSets suitable for databases and other stateful systems.

---

## 🧪 5. Scaling & Rolling Updates (Optional)

### Scale replicas

You can scale the StatefulSet up or down:

```bash
kubectl scale statefulset/mysql --replicas=2
kubectl get pods -l app=mysql
```

Kubernetes will terminate Pods in reverse ordinal order (`mysql-2` before `mysql-1`, etc.), preserving PVCs for potential future use.

### Rolling update of MySQL image

If you change the MySQL image version (for example to `mysql:8.1`) in the manifest and re-apply it, Kubernetes will perform a **rolling update** of the Pods in ordinal order, respecting the StatefulSet guarantees.

---

## 🧹 6. Cleanup

When you are done with the lab, delete the resources:

```bash
kubectl delete -f k8s/mysql-statefulset.yaml
```

> ⚠️ **Warning:**  
> Depending on your StorageClass reclaim policy, deleting the StatefulSet and Service may **not** delete the underlying PersistentVolumes.  
> Check PVs and PVCs with:

```bash
kubectl get pvc
kubectl get pv
```

If you want to fully clean up, you may need to manually delete PVCs/PVs (only in a lab environment).

---

## 📚 Summary

In this lab you:

- Deployed **MySQL** on Kubernetes using a **StatefulSet**
- Provisioned **persistent storage per replica** via `volumeClaimTemplates`
- Exposed the StatefulSet using a **headless Service** with stable DNS names
- Connected to MySQL inside a Pod and stored data

This pattern is a common starting point for running stateful databases in Kubernetes.  
You can extend this lab by:

- Adding a dedicated MySQL `ConfigMap` or `Secret` for configuration and credentials
- Exposing MySQL via a separate Service for application Pods
- Integrating MySQL with backup/restore tooling in later labs
