# Podman quadlets for bolls.life

This directory contains the production systemd quadlets used to run the stack on a Podman host.

## Current sizing baseline

The defaults in these quadlets are sized for a VPS with 4 vCPU and 8 GB RAM:

- `bolls-web.container` runs 3 gunicorn workers and is capped at 2 GB.
- `bolls-db.container` is capped at 2 GB, with PostgreSQL memory tuned around a 512 MB `shared_buffers` target.
- `bolls-nginx.container` stays small and capped at 256 MB.

This keeps roughly half of the host memory available for the OS page cache, Podman overhead, certificate renewal, deploy-time image pulls, and temporary traffic spikes.

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
