#!/bin/bash
echo "#./nfsserver <nfs server path>"
yum install -y nfs-utils rpcbind
mkdir -p $1
echo "$1 *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports
systemctl stop firewalld.service
systemctl enable rpcbind.service
systemctl enable nfs-server.service
systemctl start rpcbind.service
systemctl start nfs-server.service
rpcinfo -p

systemctl restart nfs-server.service
