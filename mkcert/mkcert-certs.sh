#!/bin/bash

set -a

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

set +a

mkcert -cert-file "$PROJECT_DIR/traefik/certs/local-cert.pem" -key-file "$PROJECT_DIR/traefik/certs/local-key.pem" "bolls.local"
