# Homepage – Konfigurationsdateien (Schritt 2)

Alle Dateien gehören nach `~/services/homepage/config/` auf dem Pi.

---

## docker.yaml

```bash
cat > ~/services/homepage/config/docker.yaml << 'EOF'
my-docker:
  socket: /var/run/docker.sock
EOF
```

---

## settings.yaml

```bash
cat > ~/services/homepage/config/settings.yaml << 'EOF'
title: Skylla Dashboard
theme: dark
color: slate
headerStyle: clean
language: de
EOF
```

---

## widgets.yaml

```bash
cat > ~/services/homepage/config/widgets.yaml << 'EOF'
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
EOF
```

---

## services.yaml

```bash
cat > ~/services/homepage/config/services.yaml << 'EOF'
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

    - Caddy:
        icon: caddy.png
        description: Reverse Proxy
        server: my-docker
        container: caddy
EOF
```

---

## bookmarks.yaml

```bash
cat > ~/services/homepage/config/bookmarks.yaml << 'EOF'
- Verwaltung:
    - Fritzbox:
        - href: http://fritz.box
    - Fritzbox extern:
        - href: https://14fgwxfa0pcyfqpn.myfritz.net:49284
    - Mailbox.org:
        - href: https://login.mailbox.org
EOF
```

---

## Alle prüfen

```bash
ls -la ~/services/homepage/config/
```

Sollte 5 Dateien zeigen: `docker.yaml`, `settings.yaml`, `widgets.yaml`, `services.yaml`, `bookmarks.yaml`
