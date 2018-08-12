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

Output:

```
roberts-MacBook-Pro:Deploy EC2 deckjockey$ ansible-playbook -i inventory/hosts playbooks/deploy-ec2.yml
[DEPRECATION WARNING]: ec2_remote_facts is kept for backwards compatibility but usage is discouraged. The module documentation
 details page may explain more about this rationale.. This feature will be removed in a future release. Deprecation warnings
can be disabled by setting deprecation_warnings=False in ansible.cfg.

PLAY [Deploy EC2 server] ******************************************************************************************************

TASK [Create EC2 Security Group (name = ansible)] *****************************************************************************
changed: [localhost]

TASK [Create EC2 instance (name = ansible-demo) with 8gb volume, install Docker, and run nginx as a container] ****************
changed: [localhost]

TASK [Get facts for all EC2 instances in the region] **************************************************************************
ok: [localhost]

TASK [Wait for web page to come up] *******************************************************************************************
ok: [localhost -> localhost] => (item={u'kernel': None, u'root_device_type': u'ebs', u'private_dns_name': u'ip-172-31-7-98.ap-southeast-2.compute.internal', u'public_ip': u'13.211.26.132', u'private_ip': u'172.31.7.98', u'id': u'i-0fb35aa250973f712', u'ebs_optimized': False, u'state': u'running', u'virtualization_type': u'hvm', u'root_device_name': u'/dev/xvda', u'ramdisk': None, u'block_device_mapping': {u'/dev/xvda': {u'status': u'attached', u'delete_on_termination': True, u'volume_id': u'vol-096d7b8a8dad56b40'}}, u'key_name': u'EC2_Key', u'image_id': u'ami-39f8215b', u'tenancy': u'default', u'groups': {u'sg-015c60fecbf31ca57': u'ansible'}, u'public_dns_name': u'ec2-13-211-26-132.ap-southeast-2.compute.amazonaws.com', u'state_code': 16, u'tags': {u'Name': u'ansible-demo'}, u'placement': u'ap-southeast-2b', u'ami_launch_index': u'0', u'dns_name': u'ec2-13-211-26-132.ap-southeast-2.compute.amazonaws.com', u'region': u'ap-southeast-2', u'launch_time': u'2018-08-12T04:48:06.000Z', u'instance_type': u't2.micro', u'architecture': u'x86_64', u'hypervisor': u'xen'})

TASK [Download index.html from EC2 instance with the name ansible-demo] *******************************************************
changed: [localhost] => (item=[u'13.211.26.132'])

TASK [Run python script to count words in index.html] *************************************************************************
changed: [localhost -> localhost]

TASK [display word with highest count in index.html] **************************************************************************
ok: [localhost] => (item=The word 'nginx' appears 6 times in index.html) => {
    "item": "The word 'nginx' appears 6 times in index.html"
}

PLAY RECAP ********************************************************************************************************************
localhost                  : ok=7    changed=4    unreachable=0    failed=0   


```
