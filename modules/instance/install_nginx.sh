#!/bin/bash -xe
yum update -y
yum install -y amazon-efs-utils 
yum install -y nginx
mkdir -p /home/ec2-user/efs
/etc/init.d/nginx start
cd /home/ec2-user
mount -t efs -o tls ${Efs}:/ efs