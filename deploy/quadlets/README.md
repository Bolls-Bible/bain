# Podman quadlets for bolls.life

This directory contains the production systemd quadlets used to run the stack on a Podman host.

## Topology

The production deployment is split into three pods:

- `bolls-edge.pod` is the public ingress tier and publishes ports 80 and 443.
- `bolls-app.pod` is the application tier and runs Django.
- `bolls-db.pod` is the database tier and runs PostgreSQL.

The pods are connected through two networks:

- `bolls.network` is the shared front network used by nginx and the web app.
- `bolls-back.network` is an internal-only backend network used for web-to-db traffic.

This keeps the database off the public network and ensures external traffic enters only through nginx.

## Units

### Networks

- `bolls.network` creates the shared bridge network.
- `bolls-back.network` creates the private backend bridge network with `Internal=true`.

### Pods

- `bolls-edge.pod` creates the edge pod for the reverse proxy.
- `bolls-app.pod` creates the app pod and joins both networks.
- `bolls-db.pod` creates the database pod and joins only the backend network.

### Containers

- `bolls-nginx.container` runs nginx inside the edge pod.
- `bolls-web.container` runs Django from GHCR inside the app pod.
- `bolls-db.container` runs PostgreSQL inside the db pod.
- `bolls-certbot-init.container` requests the first certificate.
- `bolls-certbot-renew.container` keeps certificates renewed.

The deployment workflow renders these files into the runner user's `~/.config/containers/systemd/` directory and writes the environment file to `~/.config/bolls/bolls.env`.

For day-2 operations, troubleshooting, and maintenance, see [docs/PODMAN_QUADLETS_OPERATIONS.md](../../docs/PODMAN_QUADLETS_OPERATIONS.md).
