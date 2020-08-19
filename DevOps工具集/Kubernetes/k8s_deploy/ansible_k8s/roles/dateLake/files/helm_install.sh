sleep 20
helm install stable/jupyterhub --name jhub --namespace jhub --version 0.8.2 --values /etc/kubernetes/jupyterhub/config.yaml
