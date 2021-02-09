#!/bin/bash

userid=$(id --user)

if [ "$userid" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

uuid=$(uuidgen)

diskpath="/var/lib/libvirt/clusterdisks/$uuid.img"

hexoct1=$(openssl rand -hex 1)
hexoct2=$(openssl rand -hex 1)
hexoct3=$(openssl rand -hex 1)

generatedMAC="52:54:00:$hexoct1:$hexoct2:$hexoct3"



qemu-img create -f qcow2 -b /var/lib/libvirt/virtdisks/ubuntu-base.img $diskpath 

virt-install 	--virt-type kvm \
       		--name $uuid \
	        --ram 10000 \
	        --disk $diskpath,format=qcow2 \
		--network network=auto,mac=$generatedMAC \
		--graphics none \
		--os-type=linux \
		--os-variant=ubuntu20.04 \
		--boot hd \
		--noautoconsole \
		--vcpus 6
ipaddr=""

while [ -z "$ipaddr" ];do
	ipaddr=$(virsh net-dhcp-leases auto | grep $generatedMAC | grep -oP "192\.168\.91\.\d{1,3}")
done

echo "NAME: $uuid"
echo "MAC: $generatedMAC"
echo "IP: $ipaddr"
