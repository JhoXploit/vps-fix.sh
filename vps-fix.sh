#!/bin/bash

echo "== Memperbaiki sistem dpkg..."
dpkg --configure -a
apt-get install -f -y

echo "== Menghapus droplet-agent yang bermasalah..."
apt-get remove --purge -y droplet-agent

echo "== Update dan install apache2..."
apt update && apt install --reinstall apache2 -y

echo "== Menjalankan apache2..."
service apache2 restart

echo ""
echo "✅ Apache2 berhasil di-install dan dijalankan ulang!"
