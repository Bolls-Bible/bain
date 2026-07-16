# Podman Quadlets Operations Guide

This guide explains how to observe, debug, and maintain the production deployment that runs through rootless Podman Quadlets on the self-hosted GitHub Actions runner.

## 1. How the deployment is structured

The production deploy job renders the quadlet templates from `deploy/quadlets/` into the runner user's systemd directory and manages them with `systemctl --user`.

### Pod and network topology

The stack is intentionally split so only nginx is public:

- the **edge pod** publishes ports 80 and 443 and runs nginx
- the **app pod** runs Django and joins both the front and backend networks
- the **db pod** runs PostgreSQL and joins only the backend network
- `bolls-back.network` is created with `Internal=true`, so the database is not exposed directly

### Canonical source files

- Quadlet templates: `deploy/quadlets/`
- Deploy workflow: `.github/workflows/prod-deploy.yml`

### Generated runtime locations on the VPS

These are created by the workflow at deploy time:

- Quadlets: `~/.config/containers/systemd/`
- Environment file: `~/.config/bolls/bolls.env`
- App data root: `~/.local/share/bolls/`
- Static files: `~/.local/share/bolls/static_volume`
- Certificates: `~/.local/share/bolls/letsencrypt`
- PostgreSQL data: `~/.local/share/bolls/postgres`
- Nginx config: `~/.local/share/bolls/config/nginx/`

### Server path map (what is generated and copied where)

Use this as the canonical runtime map on the VPS runner account.

#### Core generated paths

- Podman user units root: `~/.config/containers/systemd/`
- Podman user config: `~/.config/containers/containers.conf`
- App environment file: `~/.config/bolls/bolls.env`
- Deployment data root: `~/.local/share/bolls/`

#### Quadlet templates rendered to user systemd directory

- `deploy/quadlets/bolls.network` -> `~/.config/containers/systemd/bolls.network`
- `deploy/quadlets/bolls-back.network` -> `~/.config/containers/systemd/bolls-back.network`
- `deploy/quadlets/bolls-edge.pod` -> `~/.config/containers/systemd/bolls-edge.pod`
- `deploy/quadlets/bolls-app.pod` -> `~/.config/containers/systemd/bolls-app.pod`
- `deploy/quadlets/bolls-db.pod` -> `~/.config/containers/systemd/bolls-db.pod` (owns the DB pod's `/dev/shm` sizing)
- `deploy/quadlets/bolls-db.container` -> `~/.config/containers/systemd/bolls-db.container`
- `deploy/quadlets/bolls-nginx.container` -> `~/.config/containers/systemd/bolls-nginx.container`
- `deploy/quadlets/bolls-certbot-init.container` -> `~/.config/containers/systemd/bolls-certbot-init.container`
- `deploy/quadlets/bolls-certbot-renew.container` -> `~/.config/containers/systemd/bolls-certbot-renew.container`
- `deploy/quadlets/bolls-web.container` -> `~/.config/containers/systemd/bolls-web.container` (with `IMAGE_TAG_PLACEHOLDER` rendered)

After `systemctl --user daemon-reload`, these become user units such as:

- `bolls-network.service`, `bolls-back-network.service`
- `bolls-edge-pod.service`, `bolls-app-pod.service`, `bolls-db-pod.service`
- `bolls-db.service`, `bolls-web.service`, `bolls-nginx.service`
- `bolls-certbot-init.service`, `bolls-certbot-renew.service`

#### Config files copied or generated during deploy

- Repository `nginx/main/nginx.conf` -> `~/.local/share/bolls/config/nginx/main/nginx.conf`
- Repository `nginx/conf.d/nginx.conf` (domain-substituted via `sed`) -> `~/.local/share/bolls/config/nginx/conf.d/nginx.conf`
- Remote download `options-ssl-nginx.conf` -> `~/.local/share/bolls/letsencrypt/options-ssl-nginx.conf`
- Remote download `ssl-dhparams.pem` -> `~/.local/share/bolls/letsencrypt/ssl-dhparams.pem`
- Secrets/vars rendered by workflow -> `~/.config/bolls/bolls.env`
- Generated Podman engine config -> `~/.config/containers/containers.conf`

#### Runtime data directories used by containers

- Static volume: `~/.local/share/bolls/static_volume`
- Certificates and ACME material: `~/.local/share/bolls/letsencrypt`
- PostgreSQL data directory: `~/.local/share/bolls/postgres`
- Nginx config root: `~/.local/share/bolls/config/nginx/`

#### ACME challenge location

- Host challenge root used by nginx/certbot: `$GITHUB_WORKSPACE/challenges`
- Challenge files created under: `$GITHUB_WORKSPACE/challenges/.well-known/acme-challenge/`

On a typical runner checkout this resolves to a path like:

- `~/actions-runner/_work/bain/bain/challenges/.well-known/acme-challenge/`

#### One-time copy into the DB container

- Repository `sql/unaccent_plus.rules` is copied at deploy time to container path:
  `/usr/share/postgresql/18/tsearch_data/unaccent_plus.rules` inside `bolls-db`

> Do not treat the generated files under `~/.config/containers/systemd/` as the source of truth. Update the templates in the repository and redeploy.

### User services managed by systemd

**Networks**

- `bolls-network.service`
- `bolls-back-network.service`

**Pods**

- `bolls-edge-pod.service`
- `bolls-app-pod.service`
- `bolls-db-pod.service`

**Containers**

- `bolls-db.service`
- `bolls-web.service`
- `bolls-nginx.service`
- `bolls-certbot-init.service`
- `bolls-certbot-renew.service`

## 2. Observing the deployment

Run all of the following as the same Linux user that owns the self-hosted runner.

### Quick health snapshot

```bash
systemctl --user status \
  bolls-back-network.service bolls-network.service \
  bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service \
  bolls-db.service bolls-web.service bolls-nginx.service --no-pager
podman pod ps
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
curl -fsS https://bolls.life/health/live/
curl -fsS https://bolls.life/health/ready/
```

### Live logs

```bash
journalctl --user -u bolls-web.service -f
journalctl --user -u bolls-nginx.service -f
journalctl --user -u bolls-db.service -f
journalctl --user -u bolls-certbot-init.service -f
journalctl --user -u bolls-certbot-renew.service -f
```

### Container-level inspection

```bash
podman logs --tail=200 bolls-web
podman logs --tail=200 bolls-nginx
podman logs --tail=200 bolls-db
podman inspect bolls-web --format '{{json .State.Health}}'
podman inspect bolls-db --format '{{json .State.Health}}'
```

### Useful in-container checks

```bash
podman exec bolls-web python manage.py check
podman exec bolls-web python manage.py showmigrations
podman exec bolls-web python manage.py migrate --noinput
podman exec bolls-web python manage.py migrate --fake bolls 0014_dictionary_search_indexes
podman exec bolls-web python manage.py migrate --fake
podman exec bolls-db sh -lc 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

## 3. Debugging common problems

### Problem: a quadlet change does not seem to apply

Symptoms:

- a service still starts with old settings
- restarting the container does not pick up a template edit

What to do:

```bash
systemctl --user daemon-reload
systemctl --user start bolls-network.service bolls-back-network.service
systemctl --user restart bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service
systemctl --user restart bolls-db.service bolls-web.service bolls-nginx.service
```

If the change came from the repository template, prefer rerunning the deploy workflow so the generated quadlets are recreated cleanly.

### Problem: user systemd is unavailable for the runner account

Symptoms:

- `systemctl --user` fails
- deploy logs mention no user systemd bus detected

Fix:

```bash
sudo loginctl enable-linger <runner-user>
sudo systemctl start user@$(id -u <runner-user>).service
```

Then log back in as the runner user and retry the deploy.

### Problem: Podman warns about cgroups or the runner environment

This deployment is intentionally configured for the runner service with:

- `cgroup_manager="cgroupfs"`
- `events_logger="file"`

Those settings are written during deploy to avoid the usual rootless runner warning noise.

### Problem: web container is unhealthy or keeps restarting

Check the service first:

```bash
systemctl --user status bolls-web.service --no-pager
journalctl --user -u bolls-web.service -n 200 --no-pager
podman logs --tail=200 bolls-web
```

Then verify the main dependencies:

```bash
podman exec bolls-web env | grep -E 'SQL_HOST|SQL_PORT|DJANGO_ALLOWED_HOSTS|DEBUG'
podman exec bolls-web curl -fsS http://localhost:8000/health/live/
podman exec bolls-web curl -fsS http://localhost:8000/health/ready/
```

Typical causes:

- bad secrets in the environment file
- database not reachable
- app startup failure after a bad image or code change

### Problem: nginx serves 502 after a web deploy

This has happened when nginx kept proxying an old upstream address after only the web container changed.

Fix by reloading both services together:

```bash
systemctl --user restart bolls-web.service
systemctl --user restart bolls-nginx.service
```

If needed, confirm the proxy container and port mappings:

```bash
podman ps --filter name=bolls-nginx
podman logs --tail=200 bolls-nginx
```

### Problem: TLS issuance or renewal is failing

Check DNS first, then inspect the certbot units:

```bash
systemctl --user status bolls-certbot-init.service bolls-certbot-renew.service --no-pager
journalctl --user -u bolls-certbot-init.service -n 200 --no-pager
journalctl --user -u bolls-certbot-renew.service -n 200 --no-pager
```

Also verify:

- ports 80 and 443 are reachable from the internet
- the domain points at the VPS
- the challenge directory is mounted correctly
- nginx is serving the ACME challenge location

### Problem: PostgreSQL is up but the app is failing queries

Start with:

```bash
systemctl --user status bolls-db.service --no-pager
podman logs --tail=200 bolls-db
podman exec bolls-db sh -lc 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\\dx"'
```

This repo expects the `unaccent` and `pg_trgm` extensions to be available after deploy.

## 4. Safe maintenance routines

### After every deploy

Run this quick checklist:

```bash
systemctl --user --no-pager --full status \
  bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service \
  bolls-db.service bolls-web.service bolls-nginx.service
podman pod ps
podman ps
curl -fsS https://bolls.life/health/live/
curl -fsS https://bolls.life/health/ready/
```

### When updating secrets or environment values

1. Change the GitHub Actions secrets or variables.
2. Rerun the deploy workflow.
3. Confirm the new values were rendered into `~/.config/bolls/bolls.env`.
4. Restart the affected services if needed.

### When changing quadlet behavior

1. Edit the source files in `deploy/quadlets/`.
2. Commit and push the change.
3. Run the production deploy workflow.
4. Verify with `systemctl --user status` and `journalctl --user`.

### When cleaning up disk space

Check usage first:

```bash
du -sh ~/.local/share/bolls/*
podman system df
```

Then prune unused images carefully:

```bash
podman image prune -a -f
podman volume prune -f
```

Only do this when you understand which images are still needed on the host.

### When the database needs maintenance

Examples:

```bash
podman exec bolls-db sh -lc 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "VACUUM (ANALYZE);"'
podman exec bolls-web python manage.py clearsessions
```

## 5. Recommended restart order

For routine application recovery, use this order:

```bash
systemctl --user restart bolls-db.service
systemctl --user restart bolls-web.service
systemctl --user restart bolls-nginx.service
```

If you changed pod or network quadlets, use the full topology restart:

```bash
systemctl --user daemon-reload
systemctl --user start bolls-network.service bolls-back-network.service
systemctl --user restart bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service
systemctl --user restart bolls-db.service bolls-web.service bolls-nginx.service
```

## 6. Incident checklist

If the site is down, collect these before making larger changes:

```bash
date
hostname
systemctl --user --no-pager --full status \
  bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service \
  bolls-db.service bolls-web.service bolls-nginx.service
journalctl --user -u bolls-web.service -n 200 --no-pager
journalctl --user -u bolls-nginx.service -n 200 --no-pager
podman pod ps
podman ps -a
podman system df
curl -I https://bolls.life/
```

This usually tells you whether the issue is:

- service startup
- app health
- database availability
- nginx proxying
- certificate renewal
- host disk pressure

## 7. Rule of thumb

If a runtime file under the runner's home directory looks wrong, ask:

1. Is the repository template correct?
2. Was the deploy workflow rerun after the change?
3. Was `systemctl --user daemon-reload` executed?
4. Were the relevant pod services and the web/nginx containers restarted?

That sequence resolves most operational issues in this setup.

### In case the wrong DB image was used

```bash
systemctl --user cat bolls-db.service | grep -F 'docker.io/library/postgres:18-trixie'
systemctl --user stop bolls-db.service || true
systemctl --user reset-failed bolls-db.service || true
podman rm -f bolls-db || true
systemctl --user start bolls-db.service
```

