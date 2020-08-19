#!/bin/bash
echo "#./nfsclient <nfs server IP>"
yum install -y nfs-utils rpcbind
systemctl enable rpcbind.service
systemctl start rpcbind.service
showmount -e $1

