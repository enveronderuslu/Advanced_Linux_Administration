#!/bin/bash

read -p "Enter Zone block of the IP (10.0.Zone.x): " ZONE
read -p "Enter IP block of the IP (10.0.x.IP): " IP
read -p "Enter the hostname (hostname.example.local): " HT

DOMAIN="example.local"

echo "--- Generating Commands ---"

# A Record Command
echo "ipa dnsrecord-add $DOMAIN $HT --a-rec 10.0.$ZONE.$IP"

# PTR Record  Command
echo "ipa dnsrecord-add $ZONE.0.10.in-addr.arpa. $IP --ptr-hostname=$HT.$DOMAIN."
