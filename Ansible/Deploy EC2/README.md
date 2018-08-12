# Deploy EC2 instance using Ansible

1. Logs the resource usage of the container every 10 seconds.

## Pre-Requisites

* mac OSX
* ansible 2.6.2
* python 2.7.15 (with addons: boto 2.49.0, boto3 1.7.75, botocore 1.10.75)


## Required Files

### EC2_Key.pem

Private key used to connect to your EC2 instance:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAyBotrLe1gq9fDsfP4/oZbF4tXfjJK9MteQO3goLEkvopKYoiGbX
-----END RSA PRIVATE KEY-----
```


### inventory\hosts

Hosts file containing the path to python to be used by ansible:

```
[local]
localhost ansible_python_interpreter=/usr/local/bin/python

```


### inventory\group_vars\all

Variable file containing the parameters used by the ansible playbooks.

Those listed in { } need to be updated with your unique AWS account information, and the { } removed, e.g. my_local_cidr_ip: 101.182.82.152/32

```
---
aws_access_key: {Access key for AWS user with admin rights}
aws_secret_key: {Secret key to match aws access key}
key_name: EC2_Key
aws_region: ap-southeast-2
vpc_id: {unique id of your VPC, can be the default VPC}
ami_id: ami-39f8215b
instance_type: t2.micro
my_local_cidr_ip: {Your internet IP address / 32}
```


### playbooks\deploy-ec2.yml

Ansible playbook that uses the ec2_group and ec2 modules, to create a security group and instance in AWS:

https://docs.ansible.com/ansible/2.5/modules/ec2_group_module.html
https://docs.ansible.com/ansible/2.5/modules/ec2_module.html


## Script Execution

From the command line, type:

```
ansible-playbook -i inventory/hosts playbooks/deploy-ec2.yml
```
