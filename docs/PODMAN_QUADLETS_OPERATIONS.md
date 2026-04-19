# Podman Quadlets Operations Guide

This guide explains how to observe, debug, and maintain the production deployment that runs through rootless Podman Quadlets on the self-hosted GitHub Actions runner.

## 1. How the deployment is structured

The production deploy job renders the quadlet templates from `deploy/quadlets/` into the runner user's systemd directory and manages them with `systemctl --user`.

### Canonical source files

- Quadlet templates: `deploy/quadlets/`
- Deploy workflow: `.github/workflows/prod-deploy.yml`

### Generated runtime locations on the VPS

These are created by the workflow at deploy time:

- Quadlets: `~/.config/containers/systemd/`
- Environment file: `~/.config/bolls/bolls-dev.env`
- App data root: `~/.local/share/bolls/`
- Static files: `~/.local/share/bolls/static_volume`
- Certificates: `~/.local/share/bolls/letsencrypt`
- PostgreSQL data: `~/.local/share/bolls/postgres`
- Nginx config: `~/.local/share/bolls/config/nginx/`

> Do not treat the generated files under `~/.config/containers/systemd/` as the source of truth. Update the templates in the repository and redeploy.

### User services managed by systemd

- `bolls-dev-network.service`
- `bolls-dev-db.service`
- `bolls-dev-web.service`
- `bolls-dev-nginx.service`
- `bolls-dev-certbot-init.service`
- `bolls-dev-certbot-renew.service`

## 2. Observing the deployment

Run all of the following as the same Linux user that owns the self-hosted runner.

### Quick health snapshot

```bash
systemctl --user status bolls-dev-db.service bolls-dev-web.service bolls-dev-nginx.service --no-pager
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
curl -fsS https://dev.bolls.life/health/live/
curl -fsS https://dev.bolls.life/health/ready/
```

### Live logs

```bash
journalctl --user -u bolls-dev-web.service -f
journalctl --user -u bolls-dev-nginx.service -f
journalctl --user -u bolls-dev-db.service -f
journalctl --user -u bolls-dev-certbot-renew.service -f
```

### Container-level inspection

```bash
podman logs --tail=200 bolls-dev-web
podman logs --tail=200 bolls-dev-nginx
podman logs --tail=200 bolls-dev-db
podman inspect bolls-dev-web --format '{{json .State.Health}}'
podman inspect bolls-dev-db --format '{{json .State.Health}}'
```

### Useful in-container checks

```bash
podman exec bolls-dev-web python manage.py check
podman exec bolls-dev-web python manage.py showmigrations
podman exec bolls-dev-db sh -lc 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

## 3. Debugging common problems

### Problem: a quadlet change does not seem to apply

Symptoms:

- a service still starts with old settings
- restarting the container does not pick up a template edit

What to do:

```bash
systemctl --user daemon-reload
systemctl --user restart bolls-dev-db.service bolls-dev-web.service bolls-dev-nginx.service
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
systemctl --user status bolls-dev-web.service --no-pager
journalctl --user -u bolls-dev-web.service -n 200 --no-pager
podman logs --tail=200 bolls-dev-web
```

Then verify the main dependencies:

```bash
podman exec bolls-dev-web env | grep -E 'SQL_HOST|SQL_PORT|DJANGO_ALLOWED_HOSTS|DEBUG'
podman exec bolls-dev-web curl -fsS http://localhost:8000/health/live/
podman exec bolls-dev-web curl -fsS http://localhost:8000/health/ready/
```

Typical causes:

- bad secrets in the environment file
- database not reachable
- app startup failure after a bad image or code change

### Problem: nginx serves 502 after a web deploy

This has happened when nginx kept proxying an old upstream address after only the web container changed.

Fix by reloading both services together:

```bash
systemctl --user restart bolls-dev-web.service
systemctl --user restart bolls-dev-nginx.service
```

If needed, confirm the proxy container and port mappings:

```bash
podman ps --filter name=bolls-dev-nginx
podman logs --tail=200 bolls-dev-nginx
```

### Problem: TLS issuance or renewal is failing

Check DNS first, then inspect the certbot units:

```bash
systemctl --user status bolls-dev-certbot-init.service bolls-dev-certbot-renew.service --no-pager
journalctl --user -u bolls-dev-certbot-init.service -n 200 --no-pager
journalctl --user -u bolls-dev-certbot-renew.service -n 200 --no-pager
```

Also verify:

- ports 80 and 443 are reachable from the internet
- the domain points at the VPS
- the challenge directory is mounted correctly
- nginx is serving the ACME challenge location

### Problem: PostgreSQL is up but the app is failing queries

Start with:

```bash
systemctl --user status bolls-dev-db.service --no-pager
podman logs --tail=200 bolls-dev-db
podman exec bolls-dev-db sh -lc 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\\dx"'
```

This repo expects the `unaccent` and `pg_trgm` extensions to be available after deploy.

## 4. Safe maintenance routines

### After every deploy

Run this quick checklist:

```bash
systemctl --user --no-pager --full status bolls-dev-db.service bolls-dev-web.service bolls-dev-nginx.service
podman ps
curl -fsS https://dev.bolls.life/health/live/
curl -fsS https://dev.bolls.life/health/ready/
```

### When updating secrets or environment values

1. Change the GitHub Actions secrets or variables.
2. Rerun the deploy workflow.
3. Confirm the new values were rendered into `~/.config/bolls/bolls-dev.env`.
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
podman exec bolls-dev-db sh -lc 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "VACUUM (ANALYZE);"'
podman exec bolls-dev-web python manage.py clearsessions
```

## 5. Recommended restart order

For routine recovery or after config changes, use this order:

```bash
systemctl --user restart bolls-dev-db.service
systemctl --user restart bolls-dev-web.service
systemctl --user restart bolls-dev-nginx.service
```

If you changed the network quadlet or regenerated units:

```bash
systemctl --user daemon-reload
systemctl --user start bolls-dev-network.service
systemctl --user restart bolls-dev-db.service bolls-dev-web.service bolls-dev-nginx.service
```

## 6. Incident checklist

If the site is down, collect these before making larger changes:

```bash
date
hostname
systemctl --user --no-pager --full status bolls-dev-db.service bolls-dev-web.service bolls-dev-nginx.service
journalctl --user -u bolls-dev-web.service -n 200 --no-pager
journalctl --user -u bolls-dev-nginx.service -n 200 --no-pager
podman ps -a
podman system df
curl -I https://dev.bolls.life/
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
4. Were both the web and nginx services restarted together?

That sequence resolves most operational issues in this setup.
