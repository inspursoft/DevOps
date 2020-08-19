#!/bin/bash

function util_done()
{
    local sleeptime=$1
    shift
    while true
    do
        "$@"
        if [ $? -eq 0 ]; then
            echo "add flannel......."
#            kubectl create -f /var/lib/yaml/snap.yaml
#            kubectl create -f /var/lib/yaml/heapster.yaml
#            kubectl create -f /var/lib/yaml/fluentd.yaml
#            kubectl create -f /var/lib/yaml/coredns.yaml
            kubectl create -f /var/lib/yaml/tiller.yaml
            kubectl create -f /var/lib/yaml/tiller-service.yaml
            
            break
        fi
        sleep $sleeptime
    done
}

function init()
{
        url=$1
        sleeptime=5
        echo "checking api server"
        util_done $sleeptime curl $url
}

init $1
