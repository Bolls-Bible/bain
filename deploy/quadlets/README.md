# Podman quadlets for dev.bolls.life

This directory contains the production systemd quadlets used to run the stack on a Podman host.

## Units

- `bolls-dev.network` creates the shared bridge network.
- `bolls-dev-db.container` runs PostgreSQL.
- `bolls-dev-web.container` runs Django from GHCR.
- `bolls-dev-nginx.container` publishes ports 80 and 443.
- `bolls-dev-certbot-init.container` requests the first certificate.
- `bolls-dev-certbot-renew.container` keeps certificates renewed.

The deployment workflow installs these files into `/etc/containers/systemd/` and writes the environment file to `/etc/bolls/bolls-dev.env`.
