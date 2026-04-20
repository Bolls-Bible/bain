## VPS Instance Setup for bolls.life with Podman Quadlets

### 1. Install Podman on the VPS

Use a host with systemd and Podman 5 or newer.

Example check:

```bash
podman --version
systemctl --version
```

### 2. Register the VPS as a GitHub self-hosted runner

In the repository settings, add a new self-hosted Actions runner for Linux x64 and install it as a system service on the VPS.

Useful GitHub documentation:

- Adding a self-hosted runner: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners
- Installing the runner as a service: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service
- Using self-hosted runners in workflows: https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners/about-self-hosted-runners

Verify that the runner is online and has the default labels:

```bash
self-hosted
Linux
X64
```

There is one "invisible" setting that often blocks self-hosted runners in organizations: Runner Groups.

1. Go to Settings > Actions > Runner groups.
2. Click on the group your runner belongs to (usually the "Default" group).
3. Check the "Allow public repositories" (if your repo is public) and "Selected repositories" settings.
4. Ensure your specific repository is allowed to use that runner group. Even if a runner is "Online," if it's in a group that isn't authorized for your repository, it will ignore the jobs.

For the rootless deployment flow, enable lingering once for the runner account so user quadlets can start without sudo:

```bash
sudo loginctl enable-linger <runner-user>
```

If the VPS should expose ports 80 and 443 directly from rootless Podman, allow unprivileged low ports once during host setup:

```bash
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee /etc/sysctl.d/99-rootless-ports.conf
```

### 3. Point DNS for bolls.life

Create the A or AAAA record for `bolls.life` and point it to the VPS before the first real TLS issuance.

### 4. Required GitHub Actions secrets and variables

Set the same production secrets already used by the workflow:

- `GH_PAT`
- `DEBUG_SECRET`, `SECRET_KEY_SECRET`
- `POSTGRES_DB_SECRET`, `POSTGRES_USER_SECRET`, `POSTGRES_PASSWORD_SECRET`
- `EMAIL_HOST_USER_SECRET`, `EMAIL_HOST_PASSWORD_SECRET`
- `SOCIAL_AUTH_GOOGLE_OAUTH2_KEY_SECRET`, `SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET_SECRET`
- `SOCIAL_AUTH_GITHUB_KEY_SECRET`, `SOCIAL_AUTH_GITHUB_SECRET_SECRET`
- variable: `DJANGO_ALLOWED_HOSTS_SECRET`
- secret: `NGINX_DOMAIN_NAME=bolls.life`

### 5. What the deploy pipeline does now

The current deployment is rootless and managed through the runner user's systemd session with `systemctl --user`.

For observation, debugging, and routine maintenance after setup, see [PODMAN_QUADLETS_OPERATIONS.md](./PODMAN_QUADLETS_OPERATIONS.md).

The production workflow now:

- builds and pushes the Django image to GHCR
- runs the deploy job directly on the VPS self-hosted runner
- checks out the repo in the runner workspace
- writes the runtime environment file to `~/.config/bolls/bolls.env`
- renders the quadlets from `deploy/quadlets/` into `~/.config/containers/systemd/`
- creates two networks: a shared front network and an internal-only backend network
- creates three pods: edge for nginx, app for Django, and db for PostgreSQL
- bootstraps TLS files and requests the certificate for `bolls.life`
- starts the stack with `systemctl --user` and Podman quadlets
- applies DB extensions and runs the Django test suite in the web container

### 6. Manual service management on the VPS

Useful commands as the runner user:

```bash
systemctl --user status bolls-back-network.service bolls-network.service
systemctl --user status bolls-db-pod.service bolls-app-pod.service bolls-edge-pod.service
systemctl --user status bolls-db.service bolls-web.service bolls-nginx.service
systemctl --user status bolls-certbot-init.service bolls-certbot-renew.service
journalctl --user -u bolls-web.service -n 200 --no-pager
podman pod ps
podman ps
```

Stream logs from the services
```bash
journalctl --user -u bolls-web.service -f
journalctl --user -u bolls-nginx.service -f
journalctl --user -u bolls-certbot-init.service -f
journalctl --user -u bolls-certbot-renew.service -f
```

### 7. Restore production data if needed

The database container name in the quadlet deployment is `bolls-db`.

```bash
wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql -O backup.sql
podman cp ./backup.sql bolls-db:/backup.sql
podman exec bolls-db psql -U <POSTGRES_USER_SECRET> -d <POSTGRES_DB_SECRET> -f /backup.sql
```

### 8. Post-deploy checks

- `https://bolls.life/health/live/` responds
- login works
- bookmarks are present and can be saved
- GitHub Actions deploy job completes successfully
