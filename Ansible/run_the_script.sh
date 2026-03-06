#!/bin/bash

# Sistemi güncelle
echo "Paket listesi güncelleniyor..."
sudo apt update

# Paketler yükseltiliyor
echo "Paketler yükseltiliyor..."
sudo apt upgrade -y

echo "Güncelleme işlemi tamamlandı."
