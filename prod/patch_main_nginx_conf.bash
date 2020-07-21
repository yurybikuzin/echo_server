#!/usr/bin/env bash
sudo grep -qxF 'include "/home/bikuzin/echo/nginx.conf";' /etc/nginx/main.conf || echo 'include "/home/bikuzin/echo/nginx.conf";' >> /etc/nginx/main.conf

