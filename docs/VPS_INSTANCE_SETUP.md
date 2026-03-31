## VPS Instance Setup (Current Production Flow)

### 1. Install nerdctl + containerd (not Docker)
Use the script in this repo:

```bash
bash docs/install_nerdctl+containerd_on_debian12.bash
```

Verify installation:

```bash
nerdctl --version
containerd --version
```

### 2. Prepare host directories and network
Create required host paths used by production compose mounts:

```bash
sudo mkdir -p /var/static/static_volume
sudo mkdir -p /var/letsencrypt
```

The deploy workflow creates networks, but you can pre-create them safely:

```bash
nerdctl network create web || true
nerdctl network create internal || true
```

### 3. Point DNS and update GitHub Actions settings
Update DNS A/AAAA records to the new host IP.

Update GitHub Actions environment/secrets used by production deploy:

- `SSH_HOST`, `SSH_PORT`, `SSH_USERNAME`, `SSH_KEY`
- `GH_PAT`
- `DEBUG_SECRET`, `SECRET_KEY_SECRET`
- `POSTGRES_DB_SECRET`, `POSTGRES_USER_SECRET`, `POSTGRES_PASSWORD_SECRET`
- `EMAIL_HOST_USER_SECRET`, `EMAIL_HOST_PASSWORD_SECRET`
- `SOCIAL_AUTH_GOOGLE_OAUTH2_KEY_SECRET`, `SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET_SECRET`
- `SOCIAL_AUTH_GITHUB_KEY_SECRET`, `SOCIAL_AUTH_GITHUB_SECRET_SECRET`
- variable: `DJANGO_ALLOWED_HOSTS_SECRET`
- `NGINX_DOMAIN_NAME`

### 4. Trigger deployment pipeline
Production deployment is triggered by:

- pushing a version tag matching `v**` (for example `v1.4.0`), or
- manual `workflow_dispatch` in GitHub Actions.

Example:

```bash
git checkout master
git pull
git tag vX.Y.Z
git push origin vX.Y.Z
```

What the pipeline now does:

- builds and pushes `ghcr.io/bolls-bible/bain/django:latest`
- SSHes to VPS, clones the repo, injects secrets into `nerdctl-compose.prod.yaml`
- ensures nerdctl networks + TLS helper files exist
- initializes certs on first deploy (`init-certs/check-certs.sh`)
- runs compose deploy, restarts nginx, applies DB extensions, runs tests

### 5. Restore production database (if needed)
Container name in prod is `db`.

Download backup on VPS:

```bash
wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql -O backup.sql
```

Restore:

```bash
nerdctl cp ./backup.sql db:/backup.sql
nerdctl exec db psql -U <POSTGRES_USER_SECRET> -d <POSTGRES_DB_SECRET> -f /backup.sql
```

Restore indexes and sequences using the repo script:

```bash
nerdctl cp ./sql/restore-indexes-sequences.sql db:/restore-indexes-sequences.sql
nerdctl exec db psql -U <POSTGRES_USER_SECRET> -d <POSTGRES_DB_SECRET> -f /restore-indexes-sequences.sql
```

### 6. Post-setup checks

- login works
- bookmarks are present
- bookmarks can be saved
- deployed API checks and tests pass in GitHub Actions