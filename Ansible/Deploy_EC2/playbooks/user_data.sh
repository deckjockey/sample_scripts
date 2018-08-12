#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
docker run -d -p 80:80 --name nginx nginx
docker run -d --name=cadvisor -p 8080:8080 --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro google/cadvisor:latest
