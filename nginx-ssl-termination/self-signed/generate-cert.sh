openssl req -x509 -nodes -newkey rsa:2048 \
-keyout selfsigned.key -out selfsigned.crt \
-days 365 -subj "/CN=example.com"

