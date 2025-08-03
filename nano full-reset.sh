#!/bin/bash

echo "🚨 WARNING: Seluruh sistem akan direset total. Lanjut? (y/n)"
read confirm
if [[ "$confirm" != "y" ]]; then
  echo "❌ Dibatalkan."
  exit 1
fi

echo "🧹 Menghapus semua file Pterodactyl..."
rm -rf /var/www/pterodactyl
rm -rf /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/systemd/system/pteroq.service
rm -rf /etc/systemd/system/panel.service
rm -rf /etc/systemd/system/wings.service
rm -rf /etc/pterodactyl

echo "🛑 Menghapus database MySQL dan user..."
mysql -u root <<EOF
DROP DATABASE panel;
DROP USER 'pterodactyl'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

echo "📦 Menghapus paket-paket yang terinstal..."
apt purge -y nginx mysql-server redis-server php* composer certbot nodejs
apt autoremove -y
apt clean

echo "🧯 Menghapus cron job Pterodactyl..."
crontab -l | grep -v 'pterodactyl' | crontab -

echo "✅ Reset selesai. Sistem dalam kondisi bersih."
echo "💡 Saran: reboot VPS dengan perintah: reboot"
