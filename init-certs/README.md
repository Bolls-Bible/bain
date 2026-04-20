# For letsencrypt certificate initialization on production

Bootstrap script for letsencrypt certificate initialization on production. It is used in the `prod-deploy.yml` workflow, but can also be used locally if needed. It creates a temporary self signed certificate for the domain, which is then used to start the nginx container and allow certbot to verify the domain ownership and obtain a valid certificate from Let's Encrypt.

Usage:

```bash
APP_DOMAIN="$APP_DOMAIN" LETSENCRYPT_DIR="$LETSENCRYPT_DIR" sh ./init-certs/check-certs.sh
```
