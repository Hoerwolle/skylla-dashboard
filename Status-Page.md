# Status-Page: Homepage Dashboard auf Skylla

Lokales Web-Dashboard das Docker-Status, System-Metriken, Dienst-Links und Backup-Status anzeigt.

**Tool**: [Homepage](https://gethomepage.dev) – Docker-native Dashboard, ~50 MB RAM, arm64-kompatibel.

---

## Was wird angezeigt

| Bereich | Inhalt |
|---|---|
| **System-Metriken** | CPU-Auslastung, RAM-Verbrauch, USB-Stick-Speicher |
| **Docker-Container** | Status (grün/rot) aller laufenden Container |
| **Dienst-Links** | Schnellzugriff auf OpenCloud, VaultWarden, Immich |
| **Backup-Status** | Zeitpunkt des letzten erfolgreichen BorgBackup-Laufs |

**Erreichbar**: `http://192.168.178.101:3000` (nur im Heimnetz, kein Extern-Zugang)

---

## Schritt 1: Verzeichnisse anlegen

```bash
mkdir -p ~/services/homepage/config
```

---

## Schritt 2: Konfigurationsdateien erstellen

### `~/services/homepage/config/docker.yaml`

Verbindet Homepage mit dem Docker-Socket (lesen der Container-Status):

```yaml
my-docker:
  socket: /var/run/docker.sock
```

### `~/services/homepage/config/settings.yaml`

```yaml
title: Skylla Dashboard
theme: dark
color: slate
headerStyle: clean
language: de
```

### `~/services/homepage/config/widgets.yaml`

System-Metriken oben auf der Seite:

```yaml
- resources:
    label: System
    cpu: true
    memory: true
    disk: /app/config       # Nicht /mnt/usbdata! Beide zeigen auf sda2, aber der Container-Namespace
                            # registriert /app/config als ersten Mount-Point des USB-Sticks (weil
                            # ~/services ein Symlink auf /mnt/usbdata/services ist). Homepage
                            # validiert Pfade über /proc/mounts → /mnt/usbdata wird nicht gefunden → 404.
    diskUnits: gigabytes

- datetime:
    text_size: xl
    format:
      timeStyle: short
      dateStyle: short
      hourCycle: h23
```

### `~/services/homepage/config/services.yaml`

Container-Status + Dienst-Links:

```yaml
- Dienste:
    - OpenCloud:
        icon: owncloud.png
        href: https://14fgwxfa0pcyfqpn.myfritz.net
        description: Cloud-Speicher & Office
        server: my-docker
        container: opencloud

    - VaultWarden:
        icon: bitwarden.png
        href: https://14fgwxfa0pcyfqpn.myfritz.net:8443
        description: Passwortmanager
        server: my-docker
        container: vaultwarden

    - Immich:
        icon: immich.png
        href: https://14fgwxfa0pcyfqpn.myfritz.net:9443
        description: Foto-Backup
        server: my-docker
        container: immich-server

    - Caddy:
        icon: caddy.png
        description: Reverse Proxy
        server: my-docker
        container: caddy

- Backup:
    - BorgBackup Status:
        icon: mdi-backup-restore
        description: Letztes Backup
        widget:
          type: customapi
          url: http://localhost:3001/backup-status
          refreshInterval: 3600000
          mappings:
            - field: last_backup
              label: Letztes Backup
            - field: status
              label: Status
```

> **Hinweis**: Der `BorgBackup Status`-Widget benötigt ein kleines Skript (→ Schritt 5). Bis BorgBackup eingerichtet ist, diesen Block einfach auskommentieren (mit `#` vor jeder Zeile).

### `~/services/homepage/config/bookmarks.yaml`

```yaml
- Verwaltung:
    - Fritzbox:
        - href: http://fritz.box
    - Fritzbox extern:
        - href: https://14fgwxfa0pcyfqpn.myfritz.net:49284
    - Mailbox.org:
        - href: https://login.mailbox.org
```

---

## Schritt 3: docker-compose.yml erweitern

In `~/services/docker-compose.yml` unter `services:` einfügen:

```yaml
  # --- Homepage (lokales Dashboard) ---
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ~/services/homepage/config:/app/config
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /mnt/usbdata:/mnt/usbdata:ro
    environment:
      PUID: 1000
      PGID: 1000
    networks:
      - proxy
    mem_limit: 80m
```

---

## Schritt 4: Container starten

```bash
cd ~/services
docker compose up -d homepage
```

**Prüfen**:
```bash
docker compose logs -f homepage
```

Wenn `Starting server on port 3000` erscheint → fertig.

**Im Browser öffnen**: `http://192.168.178.101:3000`

---

## Schritt 5: Backup-Status Widget einrichten (nach BorgBackup-Setup)

Damit der Backup-Status automatisch aktualisiert wird, schreibt das BorgBackup-Skript nach jedem Lauf eine kleine JSON-Datei:

```bash
nano /usr/local/bin/backup-status-update.sh
```

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
chmod +x /usr/local/bin/backup-status-update.sh
```

Dann im BorgBackup-Skript am Ende aufrufen:
```bash
# Am Ende von /usr/local/bin/borg-backup.sh:
/usr/local/bin/backup-status-update.sh success  # oder failure bei Fehler
```

> **Einfachere Alternative**: Bis BorgBackup läuft, reicht ein manuelles Skript das die JSON-Datei schreibt. Den Widget-Block in `services.yaml` bis dahin auskommentieren.

---

## Nützliche Befehle

```bash
# Status prüfen
docker compose ps homepage

# Logs
docker compose logs -f homepage

# Neu starten (nach Konfigurationsänderung)
docker compose restart homepage

# Aktualisieren
docker compose pull homepage && docker compose up -d homepage
```

---

## Nächste Schritte

1. [ ] Verzeichnisse anlegen + Konfigurationsdateien erstellen
2. [ ] `docker-compose.yml` erweitern
3. [ ] `docker compose up -d homepage` ausführen
4. [ ] `http://192.168.178.101:3000` im Browser öffnen
5. [ ] Backup-Status-Skript nach BorgBackup-Setup ergänzen
