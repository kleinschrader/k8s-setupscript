#!/bin/bash

IFS=

userid=$(id --user)

if [ "$userid" != "0" ]; then
	echo "Please run script as root"
	exit 1
fi

echo "W2s4c21hc3Rlcl0KCltrOHNub2Rlc10KCltjZXBobm9kZXNdCg==" | base64 -d > inventory.ini

for i in {1..3}; do
	node_co=$(./createNode.sh)
	node_name=$( echo $node_co | grep -oP "(?<=^NAME: ).+$" )
	node_ip=$( echo $node_co | grep -oP "(?<=^IP: ).+$" )

	newinv=$(sed "s/\[cephnodes\]/[cephnodes]\n$node_name ansible_host=$node_ip/g" < inventory.ini)
	echo $newinv > inventory.ini

	diskpath="/var/lib/libvirt/clusterdisks/$node_name-ceph.img"

	qemu-img create -f qcow2 $diskpath 120G	

	virsh attach-disk $node_name \
	       --source  $diskpath \
	       --target vdb \
	       --persistent \
	       --subdriver qcow2
done



k8smaster_co=$(./createNode.sh)

k8sm_name=$( echo $k8smaster_co | grep -oP "(?<=^NAME: ).+$" )
k8sm_ip=$( echo $k8smaster_co | grep -oP "(?<=^IP: ).+$" )

newinv=$(sed "s/\[k8smaster\]/[k8smaster]\n$k8sm_name ansible_host=$k8sm_ip/g" < inventory.ini)
echo $newinv > inventory.ini

for i in {1..5}; do
	node_co=$(./createNode.sh)
	node_name=$( echo $node_co | grep -oP "(?<=^NAME: ).+$" )
	node_ip=$( echo $node_co | grep -oP "(?<=^IP: ).+$" )

	newinv=$(sed "s/\[k8snodes\]/[k8snodes]\n$node_name ansible_host=$node_ip/g" < inventory.ini)
	echo $newinv > inventory.ini
done
