# Welcome to Lab 2

Please make sure you have read through Lab 1 to get started. We are now going to build out a few things in this lab. This would be a VPC, an EC2 Server, and finally a set of outputs. The goal of this lab will be to build a Bastion Host that accepts SSH Inbound. That will just show how to build a single machine in automation. 

## Getting started with VPCs

**Step 1.** Let's next move into building a few systems, to do this we will need at a minimum a VPC. 


    ```
    cd ../Lab2
    ```

    ```
    nano vpc.tf
    ```

Let's paste in some code items, we are going to describe these while we insert them.

    ```
    # Pulls in the data of availability zones in the given datacenter.
    data "aws_availability_zones" "available" {
    }

    # Remember to use the Subnet from the previous exercise.
    resource "aws_subnet" "main" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    }
    ```

There are a few things in here that we need to discuss. The first one is this line:

    ```
    vpc_id            = aws_vpc.main.id
    ```

This `vpc_id` is `aws_vpc.main.id`. This is what we discussed previously. This will insert the VPC ID from the previous resource. 

The next line is:

    ```
    availability_zone = data.aws_availability_zones.available.names[0]
    ```

This is a new learning module for you, the first part of this is the `data` element which inserts an already created item. The data element in this case comes from:

Now let's continue pasting items in.

    ```
    # Create an Internet Gateway, and attach it to the VPC.
    resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    }
    ```

The next thing we are adding is the Internet Gateway which is used to communicate between our VPC and the internet. 

    ```
    # This is the routing table for the public subnet, this builds the objects and the routes are added to this table.
    resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    }
    

    # This is the route table for the public subnet, only a generic 0/0 route is needed.
    resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
    }
        
    #This associates the route table to the subnet
    resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.main.id
    route_table_id = aws_route_table.public.id
    }
    ```

Now we have a new set of items we need to add. These are the routing table elements to route to the internet. As we are adding all of these in. Do you see how we are dynamically associating items using terraforms' language?

Notice for example here:

    ```
    subnet_id      = aws_subnet.main.id
    route_table_id = aws_route_table.public.id
    ```

What this does is that this will associate a subnet that we created to the routing table we created. We do not need to worry about statically defining these values, nor do we want to. 

**Step 2.** Next, let's plan and apply these changes, let's also use some new tools.

    ```
    tflint
    ```

    This is the terraform linter. The linter is going to throw out a warning:

    ```
    1 issue(s) found:

    Warning: terraform "required_version" attribute is required (terraform_required_version)

    on provider.tf line 2:
    2: terraform {

    Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.8.0/docs/rules/terraform_required_version.md
    ```

This tells us that we have a rule violation. Let's fix that by opening up `provider.tf`. Make the file look like the following:

    ```
    # First, require the latest providers for terraform, specifically we are going use the AWS Provider, and a version of 5.0 or greater.
    terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
      }
      required_version = "~> 1.9.0"
    }

    # Configure this provider to the region that you are assigned. By default we are going ot use us-east-1.
    provider "aws" {
    region = var.region
    }
    ```

This now corrected the linter if you run `tflint` again it will not return an error. 

    ```
    terraform fmt
    ```

The terraform fmt command will make each terraform file come out in a pretty well-defined format. 

    ```
    terraform apply
    ```

Terraform apply will then run and provide us with a question, make sure you answer `yes` to run the entire job. 

## Setting up EC2

**Step 3.** We are now going to be putting an EC2 server in the environment, to do this we are going to need to first get an AMI in each datacenter. We will use an Ubuntu image for now to simplify things. Create the following file:

    ```
    nano data.tf
    ```

Insert the following lines:

    ```
    data "aws_ami" "ubuntu" {
      most_recent = true

      filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
      }

      filter {
        name   = "virtualization-type"
        values = ["hvm"]
      }

    owners = ["099720109477"] # Canonical
    }        
    ```

This will select the AWS AMI for the 22.04 release of Ubuntu.

**Step 4.** Next you may be tempted to use a premade SSH Key, however we can use cloud-init scripts to build our machine. Let's create a templatefile that we will use to build our templates. 

The first thing we want to do is setup an ssh-key

    ```
    ssh-keygen 
    ```

Create a Key in the default directory, if you wish to use a password that is up to you as this is a lab. Passwords are always recommended to protect your private key. 

**Step 5.** We are now going to create a template for our first build. As this will be a simple bastion first, let's see how we can build it.

    ```
    nano ec2.tmpl
    ```

    ```
    #cloud-config

    package_update: true
    package_upgrade: true
    package_reboot_if_required: true

    fqdn: ${hostname}

    users:
    %{ for user_key, user_value in users ~}
      - name: ${user_key}
        lock_passwd: true
        shell: /bin/bash
        ssh_authorized_keys:
        - ${user_value}
        sudo: ALL=(ALL) NOPASSWD:ALL
    %{ endfor ~}

    packages:
      - apt-transport-https
      - build-essential
      - ca-certificates
      - certbot
      - curl
      - gnupg
      - gnupg-agent
      - make
      - software-properties-common
      - sudo

    power_state:
      mode: reboot
      delay: 1
      message: Rebooting after installation
    ```

The above is a yaml file and these YAML files are SPACE sensitive. As such we have included a copy of it in the Lab2 folder. 

**Step 6.** To use this, you will need to modify your vars.tf file to add a new map based attribute that will parse names and SSH Keys. 


    ```
    nano vars.tf
    ```

At the end of the file add the following:

    ```
    variable "operators" {
      description = "This is a list that is fed to build local users in the VMs. This uses the username / ssh key pairing to fill out the cloud-init templates"
      type        = map(any)
      default = {
        "operator" = "THIS IS YOUR SSH KEY"
        }
    }
    ```

Notice that in this string:

    ```
        "operator" = "THIS IS YOUR SSH KEY"
    ```

Your username will be "operator" and the string that says "THIS IS YOUR SSH KEY" should be filled int with your public key. For example:

    ```
    cat ~/.ssh/id_rsa.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvbXx45/1SwFukLruG5Y6vsrWOaFtRTxUakd1HFxas4IGXXJCwoLtJqPPqrvAgPtSFG6Ad4NOdIiGaBV8fypLR+ECZqdmgr1/sp7iFGovVfV1S8eHNlHr6q/Aewo1uYNwJ2ERAqYn57U01C/G5hfyGVTMSaZZ0gQOFo/HYbA/1Yo8sFRNRctw2uArlf3P8v6RZ7Rf7oOK3MGOVwdbcMQna88r9ljM4tA0dAoXu8+wqGWfXkBkTeIOipz+vK5u/NwzJrb8bg6BjYZv41Ws6fXI1eVyxcwJAFrUv2xdMHHHwoGbNNKk9348hjF7aE/u491WCDDpudGUZkxng0JRwpVBL+A5Wb6r+ngb2v3PpjTjs/sg2HIIUB2c6i0iO44LgoavYgdXl4p5F7WQS69hZtmIYj2Q+UV0FLNSMNXh7GiG6pJAF9lcPArg7LbjQWSH1958CGJj3lCMsAjKFF5YqGH9AXAlu0z8L6KIwWmsI6VjWGTyCR2AeYKZ9miGiTnZv/hk= cloudshell-user@ip-10-130-82-117.ec2.internal
    ```

Then my operator still will look like:

    ```
    "operator" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvbXx45/1SwFukLruG5Y6vsrWOaFtRTxUakd1HFxas4IGXXJCwoLtJqPPqrvAgPtSFG6Ad4NOdIiGaBV8fypLR+ECZqdmgr1/sp7iFGovVfV1S8eHNlHr6q/Aewo1uYNwJ2ERAqYn57U01C/G5hfyGVTMSaZZ0gQOFo/HYbA/1Yo8sFRNRctw2uArlf3P8v6RZ7Rf7oOK3MGOVwdbcMQna88r9ljM4tA0dAoXu8+wqGWfXkBkTeIOipz+vK5u/NwzJrb8bg6BjYZv41Ws6fXI1eVyxcwJAFrUv2xdMHHHwoGbNNKk9348hjF7aE/u491WCDDpudGUZkxng0JRwpVBL+A5Wb6r+ngb2v3PpjTjs/sg2HIIUB2c6i0iO44LgoavYgdXl4p5F7WQS69hZtmIYj2Q+UV0FLNSMNXh7GiG6pJAF9lcPArg7LbjQWSH1958CGJj3lCMsAjKFF5YqGH9AXAlu0z8L6KIwWmsI6VjWGTyCR2AeYKZ9miGiTnZv/hk= cloudshell-user@ip-10-130-82-117.ec2.internal"
    ```

Save the vars.tf file.

**Step 7.** We also need to make sure we have a security group that lets us in.

    ```
    nano sg.tf
    ```

Insert the following:

    ```
    # Security Groups
    resource "aws_security_group" "main_sg" {
    name        = "Private East Servers"
    description = "Private East Servers"
    vpc_id      = aws_vpc.main.id

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Public Allow"
      }
    }
    ```

**Step 8.** Now that all of this is done, we can move on to building our Machine. This would be a way of doing it.

    ```
    nano ec2.tf
    ```

Insert the following

    ```
    # Ubuntu Default
    resource "local_file" "cloud_init_ubuntu" {
      content = templatefile("${path.module}/ec2.tmpl", {
        hostname = "bastion",
        users    = var.operators
      })
      filename = "./ec2.yaml"
    }

    data "local_file" "cloud_init_ubuntu" {
      filename = local_file.cloud_init_ubuntu.filename
      depends_on = [
        local_file.cloud_init_ubuntu
      ]
    }

    resource "aws_instance" "bastion" {
      ami               = data.aws_ami.ubuntu.id
      instance_type     = "t3.small"
      subnet_id         = aws_subnet.main.id # This is the aws subnet ID for the public subnet, meant to be a DMZ this is how a "Public IP" is attached to an instance.
      source_dest_check = false

      vpc_security_group_ids = [
        aws_security_group.main_sg.id # Default security group
      ]

      user_data = data.local_file.cloud_init_ubuntu.content

      metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = "1"
        http_tokens                 = "required"
      }

      tags = {
        Name        = "Bastion Host"
      }

      lifecycle {
        #ignore_changes = [
        #  ami,       # Do not remove this, any changes to the Ubuntu AMI will cause this repo to redeploy the machine
        #  user_data, # Do not remove this, any changes to the User Data will cause this machine to be rebuilt!
        #]
        #prevent_destroy = true
      }
    }
    ```

**Step 9.** Now we need to run a few commands to clean things up and initialize the template module that we have just added.

    ```
    terraform init
    ```

    ```
    terraform fmt
    ```

    ```
    terraform validate
    ```

    ```
    terraform apply
    ```

**Step 10.** Did you notice that you really don't have any connectivity information? Let's create an output file to help us out. Outputs can be whatever we want.

    ```
    nano output.tf
    ```

Insert the following text:

    ```
    output "final_text" {
      value = <<EOF
    -------------------------------------------------------------------------------
    Bastion Private IP:            ${try(aws_instance.bastion.private_ip, null)}
    Bastion Public IP:             ${try(aws_instance.bastion.public_ip, null)}
    -------------------------------------------------------------------------------
    EOF
    }
    ```

Rerun the terraform apply.
