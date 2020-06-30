#/ansible_k8s/ssh.sh ${PASS} ${SSH_IP}
log_name=${LOG_TIMESTAMP}.log
log_dir=/tmp/log
hosts_dir=/tmp/hosts_dir
log=${log_dir}/${log_name}
/ansible_k8s/ssh.sh ${NODE_PASS} ${NODE_IP}
/ansible_k8s/ssh.sh ${MASTER_PASS} ${MASTER_IP}
echo ${ADMIN_SERVER_IP} >> ${log}
echo ${ADMIN_SERVER_PORT} >> ${log}
echo ${INSTALL_FILE} >> ${log}
echo ${HOSTS_FILE} >> ${log}
echo ${LOG_ID} >>${log}
cd /ansible_k8s
ansible-playbook -i $hosts_dir/${HOSTS_FILE} ${INSTALL_FILE}.yml >> ${log}



#ADMIN_SERVER_IP=10.110.25.227
#ADMIN_SERVER_PORT=8080
#LOG_ID=5
#NODE_IP=192.168.122.10
#HOSTS_FILE=test
#log_name=1584435991.log
result=$?


curl -X PUT \
  http://$ADMIN_SERVER_IP:$ADMIN_SERVER_PORT/v1/admin/node/callback \
  -H 'Content-Type: application/json' \
  -d '{"log_id": '$LOG_ID', "ip": "'"$NODE_IP"'", "install_file": "'"$INSTALL_FILE"'","log_file": "'"$log_name"'","success": '$result'}'

#ansible-playbook -i hostsdir/${HOST_FILE} ${YML_FILE}.yml >> /tmp/t.txt
