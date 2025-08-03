#!/bin/bash

echo "======================================="
echo "   JhoXploit VPS Auto Fix Script"
echo "======================================="
sleep 1

echo "[1] Updating sistem..."
apt update && apt upgrade -y

echo "[2] Install paket dasar..."
apt install curl wget unzip sudo git ufw -y

echo "[3] Install / perbaiki Apache..."
apt install apache2 -y
systemctl enable apache2
systemctl restart apache2

echo "[4] Setting firewall UFW (port 80, 443, 22)..."
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

echo "[5] Menampilkan status Apache..."
systemctl status apache2 | head -n 10

echo "======================================="
echo "✔ Fix VPS Selesai!"
echo "Script by: JhoXploit"
echo "======================================="
