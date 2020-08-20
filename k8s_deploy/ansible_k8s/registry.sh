vir=(python:latest redis:latest hello-world:latest busybox:latest ubuntu:14.04 alpine:3.5 tomcat:8 golang:1.8.3 mysql:5.6.35 java:latest nginx:1.11.5 board-perf:latest)
ip=$1
for i in ${vir[@]}; do

  echo $i
  docker tag $i $ip:5000/library/$i
  docker push $ip:5000/library/$i
done

