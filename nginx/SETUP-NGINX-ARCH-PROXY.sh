sudo useradd -m -U http

# Logs
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/log/nginx/archmirror
sudo chown -R http:http /var/log/nginx
sudo chmod -R 750 /var/log/nginx

# Cache
sudo mkdir -p /var/cache/nginx/archmirror
sudo chown -R http:http /var/cache/nginx
sudo chmod -R 750 /var/cache/nginx

# Web Root
sudo mkdir -p /srv/http/pacman-cache
sudo chown -R http:http /srv/http/pacman-cache
sudo chmod -R 755 /srv/http/pacman-cache

# Remove Optional Path if Unused
# if [ -d /srv/www ]; then
#   sudo chown -R http:http /srv/www
#   sudo chmod -R 755 /srv/www
# fi
