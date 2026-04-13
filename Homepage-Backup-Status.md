# Homepage – Backup-Status-Widget (Schritt 5)

Zeigt im Dashboard wann das letzte BorgBackup erfolgreich war.

**Voraussetzung**: BorgBackup ist eingerichtet (siehe [[../BorgBackup-Setup|BorgBackup – Backup-Anleitung *(bis 24.03.2026: Raspberry Pi Argus; seither: Ninkear N10 Mini-PC Skylla)*]])

---

## Wie es funktioniert

Das BorgBackup-Skript schreibt nach jedem Lauf eine kleine JSON-Datei auf den USB-Stick. Homepage liest diese Datei über einen Mini-Webserver aus und zeigt sie als Widget an.

---

## Schritt 1: Status-Skript erstellen

```bash
sudo nano /usr/local/bin/backup-status-update.sh
```

Inhalt:

```bash
#!/bin/bash
STATUS_FILE=/mnt/usbdata/homepage/backup-status.json
mkdir -p /mnt/usbdata/homepage

if [ "$1" = "success" ]; then
  echo "{\"status\": \"OK ✅\", \"last_backup\": \"$(date '+%d.%m.%Y %H:%M')\"}" > "$STATUS_FILE"
else
  echo "{\"status\": \"FEHLER ❌\", \"last_backup\": \"$(date '+%d.%m.%Y %H:%M')\"}" > "$STATUS_FILE"
fi
```

```bash
sudo chmod +x /usr/local/bin/backup-status-update.sh
```

---

## Schritt 2: In BorgBackup-Skript einbinden

Am Ende von `/usr/local/bin/borg-backup.sh` einfügen:

```bash
# Backup-Status für Homepage aktualisieren
if [ $EXIT_CODE -eq 0 ]; then
  /usr/local/bin/backup-status-update.sh success
else
  /usr/local/bin/backup-status-update.sh failure
fi
```

---

## Schritt 3: Mini-Webserver für die JSON-Datei

Homepage braucht eine HTTP-URL, keine Datei. Dazu einen kleinen Python-Webserver als systemd-Service einrichten:

```bash
sudo nano /etc/systemd/system/backup-status-api.service
```

```ini
[Unit]
Description=Backup Status API für Homepage
After=network.target

[Service]
Type=simple
User=bastian
WorkingDirectory=/mnt/usbdata/homepage
ExecStart=/usr/bin/python3 -m http.server 3001
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now backup-status-api.service
```

**Testen**:
```bash
# Erst eine Test-Datei erzeugen
/usr/local/bin/backup-status-update.sh success

# Dann abrufen
curl http://localhost:3001/backup-status.json
```

Sollte ausgeben: `{"status": "OK ✅", "last_backup": "..."}`

---

## Schritt 4: UFW-Regel für Docker-Zugriff

Der Homepage-Container läuft in einem Docker-Netz (172.x.x.x) und braucht Zugriff auf Port 3001 des Hosts. UFW blockiert das standardmäßig.

```bash
sudo ufw allow from 172.16.0.0/12 to any port 3001 comment "Homepage → Backup Status API"
```

> `172.16.0.0/12` deckt alle Docker-Bridge-Netze ab (172.17.0.1, 172.18.0.0, usw.).

---

## Schritt 5: extra_hosts in docker-compose.yml

Damit `host.docker.internal` im Container auflösbar ist, muss der Homepage-Service in `~/services/docker-compose.yml` erweitert werden:

```yaml
  homepage:
    ...
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

---

## Schritt 6: Widget in services.yaml eintragen

In `~/services/homepage/config/services.yaml` den Backup-Block hinzufügen:

```yaml
- Backup:
    - BorgBackup:
        icon: mdi-backup-restore
        description: Letztes Backup
        widget:
          type: customapi
          url: http://host.docker.internal:3001/backup-status.json
          refreshInterval: 3600000
          mappings:
            - field: last_backup
              label: Letztes Backup
            - field: status
              label: Status
```

> ⚠️ **Nicht** `http://192.168.178.101:3001` verwenden – der Container kann die Host-LAN-IP nicht direkt erreichen, nur über `host.docker.internal`.

Dann Homepage neu starten:

```bash
cd ~/services && docker compose restart homepage
```

---

## Testen

```bash
# Erfolgreichen Backup simulieren
/usr/local/bin/backup-status-update.sh success

# Aus dem Container heraus testen
docker exec homepage wget -qO- http://host.docker.internal:3001/backup-status.json

# Widget im Browser prüfen
# http://192.168.178.101:3000
```
