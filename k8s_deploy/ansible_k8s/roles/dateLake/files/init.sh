#!/bin/bash

function util_done()
{
    local sleeptime=$1
    shift
    while true
    do
        "$@"
        if [ $? -eq 0 ]; then
            echo "nohup helm server ......."
            nohup helm serve --address 0.0.0.0:8879 &
            
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
