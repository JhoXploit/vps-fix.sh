
#!/bin/bash
apt update && apt upgrade -y
apt install apache2 -y
systemctl enable apache2
systemctl restart apache2
echo "Apache2 berhasil di-reinstall dan dijalankan ulang!"
