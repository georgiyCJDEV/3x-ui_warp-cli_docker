#!/bin/bash
set -e

WARP_REG_FILE="/var/lib/cloudflare-warp/reg.json"

# Start daemon
warp-svc & 
sleep 5

# Register cloudflare warp
if [ -f "$WARP_REG_FILE" ] && jq -e '.registration_id and .api_token' "$WARP_REG_FILE" >/dev/null; then
    echo "WARP already registered"
else
    echo "Registering WARP..."
    warp-cli --accept-tos registration new
fi

# Setup proxy and connect
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port 40000
warp-cli --accept-tos connect
warp-cli --accept-tos status

# To access WARP from docker network via container_name:40001
socat TCP-LISTEN:40001,fork,reuseaddr TCP:127.0.0.1:40000 &

# Keepalive container
tail -f /dev/null