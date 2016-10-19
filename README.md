# Concourse CI Stack

This project provisions a [ConcourseCI][1] environment using [terraform][2] and
AWS ECS.

It is designed to be imported as a Terraform module. Provide any variables / overrides that are defined within `constants.tf` and `variables.tf`.

## Features

The terraform project provisions the following resources:

- A VPC with appropriate subnets, NAT gateways and security groups.
- Two ECS clusters with EC2 instances in auto-scaling groups
    - An admin cluster that runs ConcourseCI's web service
    - A worker cluster that runs ConcourseCI workers
    - Task definitions and services are setup
- CloudWatch log groups are setup to capture logs from ECS tasks
- An RDS instance that is used by ConcourseCI
    - It is bootstrapped as part of the admin task definition
- ELBs integrated with ECS admin service
- A subdomain added under `.demo.ardel.io` with SSL (on the ELB)
- All resources are tagged with project name, type (CD) and team.

## Prerequisites

- Terraform 0.6.16+
- AWS CLI 1.10+ (this requires to publish docker images to ecr registry)
- A Github OAuth app for your environment
    - Set the website to `https://<team>-cd-<project>.demo.ardel.io`
    - Set the redirect url to `https://<team>-cd-<project>.demo.ardel.io/auth/github/callback`
    - You will be asked to set `<team>` and `<project>` when provisioning

## Usage

### `publish`

This task is used to create and publish all necessary docker images into ECR registry

**Important:** Without these images ECS cluster wont start.

```
AWS_ACCOUNT=<aws-account-id> ECR_REGION=<aws-region> make publish
```

## TODO

 - (✓) Upgrade to latest ConcourseCI version

[1]: http://concourse.ci
[2]: https://www.terraform.io
