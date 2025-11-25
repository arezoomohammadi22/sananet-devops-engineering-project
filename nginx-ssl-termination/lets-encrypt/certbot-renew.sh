#!/bin/bash

# Renew certificates silently
/usr/bin/certbot renew --quiet

# Reload Nginx if renewal was successful
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "$(date): SSL renewed and nginx reloaded." >> /var/log/ssl-renew.log
else
    echo "$(date): Renewal failed!" >> /var/log/ssl-renew.log
fi

