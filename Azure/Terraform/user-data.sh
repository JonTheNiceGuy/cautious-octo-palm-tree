#! /bin/bash -x
apt install -y apache2
echo "<html><head><title>$(hostname)</title></head><body><h1>$(hostname)</h1></body></html>" > /var/www/html/index.html
/bin/systemctl start apache2