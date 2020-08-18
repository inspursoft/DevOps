local_host="`hostname --fqdn`"
local_ip=`host $local_host 2>/dev/null | awk '{print $NF}'`
echo $local_ip
sed -i s/"master_ip_address"/"$local_ip"/g /var/lib/yaml/flannel.yml
