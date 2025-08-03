#!/bin/bash

# Update sistem & install dependensi
apt update && apt upgrade -y
apt install -y nginx mysql-server php php-cli php-fpm php-mysql php-zip php-bcmath php-curl php-mbstring php-xml php-gd unzip curl git redis-server composer certbot python3-certbot-nginx

# Setup database
mysql -u root <<EOF
CREATE DATABASE panel;
CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '1';
GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

# Install Panel
cd /var/www
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
mkdir -p pterodactyl && tar -xzvf panel.tar.gz -C pterodactyl --strip-components=1
cd pterodactyl
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force

# Konfigurasi ENV
sed -i "s/APP_URL=.*/APP_URL=https:\/\/privatejho.duckdns.org/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=panel/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=pterodactyl/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=1/" .env
php artisan migrate --seed --force

# Buat user admin (Jho/1)
php artisan p:user:make --email=jho@domain.com --username=Jho --name-first=Jho --name-last=Admin --password=1 --admin=1

# Ownership
chown -R www-data:www-data /var/www/pterodactyl

# Setup Nginx
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name privatejho.duckdns.org;
    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# SSL Let's Encrypt
certbot --nginx -d privatejho.duckdns.org --non-interactive --agree-tos -m admin@privatejho.duckdns.org

echo "✅ Pterodactyl Panel sudah diinstal di https://privatejho.duckdns.org"
