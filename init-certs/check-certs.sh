#!/bin/sh
set -eu

APP_DOMAIN="${APP_DOMAIN:-bolls.life}"
LETSENCRYPT_ROOT="${LETSENCRYPT_DIR:-/var/letsencrypt}"
CERT_DIR="$LETSENCRYPT_ROOT/live/$APP_DOMAIN"

if [ ! -f "$CERT_DIR/fullchain.pem" ]; then
    echo "No existing certificates found for $APP_DOMAIN. Creating a temporary self-signed certificate..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
        -keyout "$CERT_DIR/privkey.pem" \
        -out "$CERT_DIR/fullchain.pem" \
        -subj "/CN=$APP_DOMAIN"
    echo "Bootstrap certificate created at $CERT_DIR"
else
    echo "Existing certificates found for $APP_DOMAIN. Skipping bootstrap certificate creation."
fi
