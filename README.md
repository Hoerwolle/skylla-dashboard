# Skylla Dashboard

Lokales Web-Dashboard auf Skylla (Ninkear N10 Mini-PC) – erreichbar unter `http://192.168.178.101:3000`.

> **Hinweis:** Dieses Repository enthält die Konfigurationsdateien und Dokumentation für das Dashboard, das auf dem Skylla-Server läuft. Die Originaldateien stammen aus dem Verzeichnis `/home/bastian/opencloud/coffeeproject/Projekt DeGoogle/Skylla Dashboard`.

## Übersicht

Das Dashboard verwendet [Homepage](https://gethomepage.dev), ein Docker-natives Dashboard, das System-Metriken, Docker-Container-Status, Dienst-Links und Backup-Status anzeigt.

### Abgefragte lokale Dienste

1. **Immich**: Foto-Backup und -verwaltung
2. **OpenCloud**: Cloud-Speicher & Office
3. **VaultWarden**: Passwortmanager
4. **Caddy**: Reverse Proxy
5. **Scuttle**: Selbstgehostete Social-Media-Alternative
6. **SpritpreisTracker**: Tracking von Spritpreisen
7. **Backup**: BorgBackup-Status
8. **Server-Daten**: CPU, RAM, Speicherplatz

## Dateien

| Datei | Inhalt |
|---|---|
| [01 - status.md](01%20-%20status.md) | Aktueller Stand des Dashboards |
| [Homepage-Config-Dateien.md](Homepage-Config-Dateien.md) | Konfigurationsdateien für Homepage |
| [Homepage-Docker-Compose.md](Homepage-Docker-Compose.md) | Docker-Compose-Konfiguration |
| [Homepage-Backup-Status.md](Homepage-Backup-Status.md) | Backup-Status-Widget-Einrichtung |
| [Status-Page.md](Status-Page.md) | Gesamtanleitung und Schritte |

## Einrichtung

1. **Verzeichnisse anlegen**:
   ```bash
   mkdir -p ~/services/homepage/config
   ```

2. **Konfigurationsdateien erstellen**:
   - `docker.yaml`: Verbindung zum Docker-Socket
   - `settings.yaml`: Dashboard-Einstellungen
   - `widgets.yaml`: System-Metriken
   - `services.yaml`: Dienst-Links und Container-Status
   - `bookmarks.yaml`: Schnellzugriffs-Links

3. **Docker-Compose erweitern**:
   - Füge den Homepage-Service zur `docker-compose.yml` hinzu.

4. **Container starten**:
   ```bash
   cd ~/services
   docker compose up -d homepage
   ```

5. **Backup-Status einrichten**:
   - Erstelle das Backup-Status-Skript und integriere es in das BorgBackup-Skript.

## Nützliche Befehle

```bash
# Status prüfen
docker compose ps homepage

# Logs
docker compose logs -f homepage

# Neu starten
docker compose restart homepage

# Aktualisieren
docker compose pull homepage && docker compose up -d homepage
```

## Lizenz

Dieses Projekt ist lizenziert unter der MIT-Lizenz. Siehe die [LICENSE](LICENSE)-Datei für Details.
