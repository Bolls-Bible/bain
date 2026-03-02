if [ ! -f "/var/letsencrypt/live/bolls.life/fullchain.pem" ]; then
    echo "No existing certificates found. Creating dummy certificate for bolls.life..."
    
    # spin up dummy nginx to pass challenge through it and get the certificate.
    nerdctl compose -f nerdctl-compose.yaml up --abort-on-container-exit
    nerdctl compose -f nerdctl-compose.yaml down
    
    echo "Certificate created at /var/letsencrypt/live/bolls.life"
else
    echo "Existing certificates found for bolls.life. Skipping dummy certificate creation."
fi
