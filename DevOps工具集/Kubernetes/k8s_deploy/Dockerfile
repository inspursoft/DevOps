FROM ansible/centos7-ansible

RUN yum -y install python34 expect&& \
    ln -s /usr/bin/python3.4 /usr/bin/python3 && \
    ln -s /usr/bin/python3.4m /usr/bin/python3m

ADD ansible_k8s /ansible_k8s
ENTRYPOINT ["sh","/ansible_k8s/e.sh"] 
