# Podman quadlets for bolls.life

This directory contains the production systemd quadlets used to run the stack on a Podman host.

## Units

- bolls.network creates the shared bridge network.
- bolls-db.container runs PostgreSQL.
- bolls-web.container runs Django from GHCR.
- bolls-nginx.container publishes ports 80 and 443.
- bolls-certbot-init.container requests the first certificate.
- bolls-certbot-renew.container keeps certificates renewed.

The deployment workflow renders these files into the runner user's ~/.config/containers/systemd/ directory and writes the environment file to ~/.config/bolls/bolls.env.

For day-2 operations, troubleshooting, and maintenance, see [docs/PODMAN_QUADLETS_OPERATIONS.md](../../docs/PODMAN_QUADLETS_OPERATIONS.md).
