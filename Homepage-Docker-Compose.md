# Homepage – docker-compose.yml Erweiterung (Schritt 3)

Den folgenden Block an die bestehende `~/services/docker-compose.yml` anhängen.

---

## Anhängen per Befehl

```bash
cat >> ~/services/docker-compose.yml << 'EOF'

    homepage:
      image: ghcr.io/gethomepage/homepage:latest
      container_name: homepage
      restart: unless-stopped
      ports:
        - "3000:3000"
      environment:
        HOMEPAGE_ALLOWED_HOSTS: "192.168.178.101:3000"
      volumes:
        - ./homepage/config:/app/config
        - /var/run/docker.sock:/var/run/docker.sock:ro
        - /mnt/usbdata:/mnt/usbdata:ro
      networks:
        - proxy
      mem_limit: 80m
      extra_hosts:
        - "host.docker.internal:host-gateway"
EOF
```

> **Hinweis**: `HOMEPAGE_ALLOWED_HOSTS` ist ab Homepage v1.0 erforderlich. Ohne diese Variable werden Anfragen mit "Host validation failed" blockiert.

---

## YAML-Syntax prüfen

```bash
docker compose -f ~/services/docker-compose.yml config --quiet && echo "✅ YAML OK" || echo "❌ Fehler"
```

---

## Container starten

```bash
cd ~/services
docker compose up -d homepage
```

**Logs beobachten** (Ready-Meldung abwarten):

```bash
docker compose logs -f homepage
```

Wenn `Started server on port 3000` erscheint → fertig.

**Im Browser öffnen**: `http://192.168.178.101:3000`

---

## Komplette docker-compose.yml zur Kontrolle

```yaml
networks:
    proxy:
      driver: bridge

volumes:
    caddy_data:
    caddy_config:
    opencloud_data:
    opencloud_config:
    vaultwarden_data:

services:
    caddy:
      image: caddy:2-alpine
      container_name: caddy
      restart: unless-stopped
      ports:
        - "80:80"
        - "443:443"
        - "8443:8443"
      volumes:
        - ./caddy/Caddyfile:/etc/caddy/Caddyfile
        - caddy_data:/data
        - caddy_config:/config
      networks:
        - proxy

    opencloud:
      image: owncloud/ocis:latest
      container_name: opencloud
      restart: unless-stopped
      entrypoint: /bin/sh
      command: ["-c", "ocis init || true && ocis server"]
      environment:
        OCIS_URL: https://14fgwxfa0pcyfqpn.myfritz.net
        PROXY_HTTP_ADDR: 0.0.0.0:9200
        OCIS_INSECURE: "false"
        PROXY_TLS: "false"
        IDM_ADMIN_PASSWORD: "rHxKOLV+0xccvFFvKo5D3eKT"
        OCIS_LOG_LEVEL: warn
      volumes:
        - opencloud_config:/etc/ocis
        - opencloud_data:/var/lib/ocis
      networks:
        - proxy

    vaultwarden:
      image: vaultwarden/server:latest
      container_name: vaultwarden
      restart: unless-stopped
      environment:
        DOMAIN: "https://14fgwxfa0pcyfqpn.myfritz.net:8443"
        SIGNUPS_ALLOWED: "false"
        WEBSOCKET_ENABLED: "true"
        LOG_LEVEL: "warn"
        ADMIN_TOKEN: "zSs53ZcTMIf1VVfPJLNeZ1aIO97c/jGGSUy4qc/12T+EyoIyAkmjJaiRpQfB3S6b"
      volumes:
        - vaultwarden_data:/data
      networks:
        - proxy

    homepage:
      image: ghcr.io/gethomepage/homepage:latest
      container_name: homepage
      restart: unless-stopped
      ports:
        - "3000:3000"
      environment:
        HOMEPAGE_ALLOWED_HOSTS: "192.168.178.101:3000"
      volumes:
        - ./homepage/config:/app/config
        - /var/run/docker.sock:/var/run/docker.sock:ro
        - /mnt/usbdata:/mnt/usbdata:ro
      networks:
        - proxy
      mem_limit: 80m
      extra_hosts:
        - "host.docker.internal:host-gateway"    # Zugriff auf Host-Services (z.B. Backup-Status-API Port 3001)
```
