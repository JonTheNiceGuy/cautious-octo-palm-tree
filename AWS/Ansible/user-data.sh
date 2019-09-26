#! /bin/bash -x
yum install -y httpd
echo "<html><head><title>WebApp1 - $(hostname)</title></head><body><h1>WebApp1- $(hostname)</h1></body></html>" > /var/www/html/index.html
/bin/systemctl start httpd