#!/bin/bash

echo "Yeni ubuntu sanal makine ismi"
read user

echo "Sanal makine IP si"
sudo virsh domifaddr $user

