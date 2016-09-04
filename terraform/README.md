# sensible-vpc

Builds an AWS VPC with subnets, NAT gateways and security groups.

## Build

    export TF_VAR_aws_access_key=<your_access_key>
    export TF_VAR_aws_secret_key=<your_secret_key>
    export TF_VAR_name=myvpc  # Set a base name for your VPC and related resources

    terraform get
    terraform plan
    terraform apply

## Description

### Subnets

We define 5 types of subnets that are created in each availability zone in a given region: public, private, data, admin and highrisk. The subnets are configured using CIDR blocks with 21 leading bits allowing roughly 2048 IPs per subnet.

So for example in `ap-southeast-2`, which has 3 availability zones, we will have 3 of each subnet type yielding 15 total subnets.

##### Public

Used for placing front-end services like Nginx, HAProxy

##### Private

Hosts services that should not be directly accessible over the internet e.g. Kubernetes nodes and application servers.

Example: You deploy your node.js app in each private subnet and have nginx or haproxy deployed in the public subnets proxying traffic to them

##### Data

Used for placing databases and other data stores that may only be accessed by private, admin and highrisk services.

##### Admin

Used for placing services that help with coordination such as Mesos master and consul clusters.

##### Highrisk

Used for placing bastion servers such as SSH jump hosts or OpenVPN Access Servers.

### Security groups

Security groups are also defined in this configuration that can be associated with EC2 instances and relevant service. These correspond in definition with the subnet types, so there are public, private, data, admin and highrisk security groups.


