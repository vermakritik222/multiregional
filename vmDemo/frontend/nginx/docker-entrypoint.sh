#!/bin/bash
set -e

# Substitute environment variable in Nginx configuration template
envsubst '${BACKEND_API_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nginx
exec nginx -g 'daemon off;'
