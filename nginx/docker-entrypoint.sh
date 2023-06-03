#!/bin/bash
set -e

# Substitute environment variable in Nginx configuration template
envsubst '${REACT_APP_API_URL}' < ./default.conf.template > /etc/nginx/conf.d/default.conf

# Start Nginx
exec nginx -g 'daemon off;'
