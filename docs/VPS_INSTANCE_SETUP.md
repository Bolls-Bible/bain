## VPS Instance Setup for dev.bolls.life with Podman Quadlets

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

### 3. Point DNS for dev.bolls.life

Create the A or AAAA record for `dev.bolls.life` and point it to the VPS before the first real TLS issuance.

### 4. Required GitHub Actions secrets and variables

Set the same production secrets already used by the workflow:

- `GH_PAT`
- `DEBUG_SECRET`, `SECRET_KEY_SECRET`
- `POSTGRES_DB_SECRET`, `POSTGRES_USER_SECRET`, `POSTGRES_PASSWORD_SECRET`
- `EMAIL_HOST_USER_SECRET`, `EMAIL_HOST_PASSWORD_SECRET`
- `SOCIAL_AUTH_GOOGLE_OAUTH2_KEY_SECRET`, `SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET_SECRET`
- `SOCIAL_AUTH_GITHUB_KEY_SECRET`, `SOCIAL_AUTH_GITHUB_SECRET_SECRET`
- variable: `DJANGO_ALLOWED_HOSTS_SECRET`
- secret: `NGINX_DOMAIN_NAME=dev.bolls.life`

### 5. What the deploy pipeline does now

The production workflow now:

- builds and pushes the Django image to GHCR
- runs the deploy job directly on the VPS self-hosted runner
- checks out the repo in the runner workspace
- writes the runtime environment file to `/etc/bolls/bolls-dev.env`
- installs the quadlets from `deploy/quadlets/` into `/etc/containers/systemd/`
- bootstraps TLS files and requests the certificate for `dev.bolls.life`
- starts the stack with `systemctl` and Podman quadlets
- applies DB extensions and verifies the health endpoint

### 6. Manual service management on the VPS

Useful commands:

```bash
sudo systemctl status bolls-dev-db.service
sudo systemctl status bolls-dev-web.service
sudo systemctl status bolls-dev-nginx.service
sudo systemctl status bolls-dev-certbot-renew.service
sudo journalctl -u bolls-dev-web.service -n 200 --no-pager
sudo podman ps
```

### 7. Restore production data if needed

The database container name in the quadlet deployment is `bolls-dev-db`.

```bash
wget https://storage.googleapis.com/resurrecting-cat.appspot.com/backup.sql -O backup.sql
sudo podman cp ./backup.sql bolls-dev-db:/backup.sql
sudo podman exec bolls-dev-db psql -U <POSTGRES_USER_SECRET> -d <POSTGRES_DB_SECRET> -f /backup.sql
```

### 8. Post-deploy checks

- `https://dev.bolls.life/health/live/` responds
- login works
- bookmarks are present and can be saved
- GitHub Actions deploy job completes successfully
