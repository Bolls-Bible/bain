# For letsencrypt certificate initialization on production

Run this when you're setting up new fresh production environment. It will create the necessary certificates for your domain using certbot.

Usage:

```bash
nerdctl compose up --abort-on-container-exit  --exit-code-from certbot-initializer
nerdctl compose down
```
