# Skylla Dashboard – Status

Lokales Web-Dashboard auf Skylla (Ninkear N10 Mini-PC) – erreichbar unter `http://192.168.178.101:3000`.

> **Hinweis:** Dieses Verzeichnis hieß bis 24.03.2026 "Argus Dashboard" (Raspberry Pi). Seither läuft das Dashboard auf Skylla.

**Tool**: [Homepage](https://gethomepage.dev) – Docker-natives Dashboard, ~50 MB RAM, arm64-kompatibel.

---

## Aktueller Stand

| Bereich | Status | Anzeige |
|---|---|---|
| **Dienst-Links** | ✅ Läuft | OpenCloud, VaultWarden, Caddy |
| **Docker-Container Status** | ✅ Läuft | Grün/Rot pro Container |
| **System-Metriken** | ✅ Läuft | CPU, RAM, USB-Stick-Füllstand |
| **Backup-Status** | ⬜ Ausstehend | Letzter BorgBackup-Lauf – wird nach Phase 6 ergänzt |

---

## Dateien

| Datei | Inhalt |
|---|---|
| [[Status-Page\|Status-Page.md]] | Gesamtanleitung: Verzeichnisse, alle Schritte, Nützliche Befehle |
| [[Homepage-Config-Dateien\|Homepage-Config-Dateien.md]] | Schritt 2: alle 5 YAML-Konfigurationsdateien mit Copy-Paste-Befehlen |
| [[Homepage-Docker-Compose\|Homepage-Docker-Compose.md]] | Schritt 3: docker-compose.yml Erweiterung + vollständige Referenz-Compose |
| [[Homepage-Backup-Status\|Homepage-Backup-Status.md]] | Schritt 5: Backup-Status-Widget einrichten (nach BorgBackup-Setup) |

---

## Nächster Schritt

**→ Backup-Status-Widget** aktivieren, sobald BorgBackup (Phase 6) eingerichtet ist.

Anleitung: [[Homepage-Backup-Status|Homepage – Backup-Status-Widget (Schritt 5)]]
