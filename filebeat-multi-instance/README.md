
# Project 3 — Multi‑Instance Filebeat (systemd template)

This project demonstrates how to run **multiple isolated Filebeat instances** on the same server using:

- A **systemd template service** (`filebeat@.service`)
- Separate Filebeat configs: `filebeat-1.yml`, `filebeat-2.yml`, ...
- Separate data/log directories per instance
- Kafka output as the sink
- Container log ingestion via Filebeat filestream/container input

This structure is suitable for production environments where each Filebeat instance must process separate log streams independently.

---

# 📁 Project Structure

```
filebeat-multi-instance/
├── configs/
│   ├── filebeat-1.yml
│   ├── filebeat-2.yml
│   └── filebeat-3.yml
├── systemd/
│   └── filebeat@.service
└── README.md
```

Each Filebeat instance is managed as:

```
sudo systemctl start filebeat@1
sudo systemctl start filebeat@2
sudo systemctl start filebeat@3
```

---

# 🧩 Filebeat Config Example (filebeat-1.yml)

```yaml
filebeat.inputs:
  - type: container
    id: my-filestream-id
    enabled: true
    paths:
      - /var/log/containers/master-payment*.log
    processors:
      - drop_fields:
          fields: ["host.ip", "host.mac", "ecs.version"]
    include_lines: ['err', 'warn']

logging.level: debug

filebeat.config.modules:
  path: /etc/filebeat/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

output.kafka:
  hosts: ['192.168.10.170:9092', '192.168.10.172:9092', '192.168.10.173:9092']
  topic: payment
  codec.json:
    pretty: false
```

You can duplicate `filebeat-1.yml` into:

```
filebeat-2.yml
filebeat-3.yml
```

Each can ingest different log paths, topics, modules, etc.

---

# 🛠 systemd Template Unit (filebeat@.service)

Put this file in:

```
/etc/systemd/system/filebeat@.service
```

Content:

```ini
[Unit]
Description=Filebeat instance %i

[Service]
Environment="GODEBUG='madvdontneed=1'"
Environment="BEAT_LOG_OPTS="
Environment="BEAT_CONFIG_OPTS=-c /etc/filebeat/filebeat-%i.yml"
Environment="BEAT_PATH_OPTS=--path.home /usr/share/filebeat --path.config /etc/filebeat/ --path.data /var/lib/filebeat/filebeat-%i --path.logs /var/log/filebeat/"
ExecStart=/usr/share/filebeat/bin/filebeat --environment systemd $BEAT_LOG_OPTS $BEAT_CONFIG_OPTS $BEAT_PATH_OPTS
Restart=always
WorkingDirectory=/

[Install]
WantedBy=multi-user.target
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

---

# 🚀 Running Filebeat Instances

### Start instance 1:
```bash
sudo systemctl start filebeat@1
```

### Start instance 2:
```bash
sudo systemctl start filebeat@2
```

### Start instance 3:
```bash
sudo systemctl start filebeat@3
```

### Enable on boot:
```bash
sudo systemctl enable filebeat@1
sudo systemctl enable filebeat@2
sudo systemctl enable filebeat@3
```

### Check status:
```bash
sudo systemctl status filebeat@1
```

---

# 📌 File Locations

| Component | Path |
|----------|------|
| Filebeat configs | `/etc/filebeat/filebeat-%i.yml` |
| Data folders | `/var/lib/filebeat/filebeat-%i/` |
| Logs | `/var/log/filebeat/` |
| systemd unit | `/etc/systemd/system/filebeat@.service` |

---

# 🧪 Testing

### Test config:
```bash
sudo -u filebeat /usr/share/filebeat/bin/filebeat test config -c /etc/filebeat/filebeat-1.yml
```

### Test output:
```bash
sudo -u filebeat /usr/share/filebeat/bin/filebeat test output -c /etc/filebeat/filebeat-1.yml
```

---

# 🛡 Notes

- Each Filebeat instance is completely independent.
- You can run unlimited instances: `filebeat@7`, `filebeat@10`, etc.
- Recommended for microservices, multi-tenant systems, or heavy log segmentation.
- Kafka output ensures high throughput for log pipelines.

---

# 👤 Author  
Arezoo Mohammadi  
DevOps Engineer  
https://sananetco.com

