# 适用环境
    Centos7.4 mini, Centos7.6 mini
# 安装配置
#### edit file ansible_k/8shosts
     [masters]
     192.168.122.44(master ip address for k8s)
     [etcd]
     192.168.122.44
     [nodes]
     192.168.122.208 
     192.168.122.175 
     all k8s nodes list
     [board]
     192.168.122.10
	 install board ip address
     [nfs-server]
     192.168.122.208
	 install nfs-server ip address
     [registry]
     192.168.122.208
	 install registry ip address
     [jenkins_node]
     192.168.122.10
	 install jenkins node ip address
#### edit file ansible_k8s/group_vars/all.yml
     
     nfs_dir: /data/nfs   # defind nfs directory
     docker_dir: /var/lib/docker # define docker directory
     credential_private_key:        # if use exist private key please give the directory else with empty
     other valuable please used the default

#### install all 
     ansible-playbook -i hosts install.yml
#### install all except jupy
     ansible-playbook -i hosts --skip-tags=juy install.yml
#### install jupy except istio
     ansible-playbook -i hosts --skip-tags=istio install.yml
#### set the k8s 
     ansible-playbook -i hosts resetk8s.yml
#### unstall all cluster
     ansible-playbook -i hosts uninstall.yml
#### add nodes to the cluster
     ansible-playbook -i addhost addnode.yml
#### How to get the install package
     curl -O "http://repo.inspur.com/artifactory/k8s-deploy-script/ansible_k8s.tar.gz"


