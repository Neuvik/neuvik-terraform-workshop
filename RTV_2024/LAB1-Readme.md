# Welcome to Lab 1

To get started have one of the items available to you:

1. Lucky enough to be one of the first few that we can provide an account.
2. Have an existing AWS Account.

Let's also discuss what you need to get going.

1. [Terraform](https://developer.hashicorp.com/terraform/install) version 1.9.0 or higher
2. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) version 2
3. AWS Access Keys on your local system OR use AWS CloudShell.

## AWS CloudShell

For those that have AWS CloudShell (which we do recommend), you can use the following installation script.

**Step 1.** Log into AWS.

**Step 2.** Open CloudShell

**Step 3.** Type the following into the CloudShell:
    
    ```
    git clone https://github.com/neuvik/neuvik-terraform-workshop
    ```

    ```
    cd neuvik-terraform-workshop/RTV_2024/Lab1
    ```

    ```
    bash quickstart.sh
    ```

**Step 4.** You should now have the Terraform Binary and the required items to work. Unfortunately if you are going to use CloudShell you will need to use one of the console text editors to do your work. This would include: `nano`, `vi`, `emacs`. Since my editor of choice is `emacs` I'll default to `nano` to save you from the pain. 

**Step 5.** Let's also make sure you have the appropriate aws credentials, please type this command: 

    ```
    aws sts get-caller-identity
    ```

You should now have something similar to the following:

    ```
    {
    "UserId": "AROA[REDACTED]F:mo[REDACTED]m",
    "Account": "02[REDACTED]73",
    "Arn": "arn:aws:sts::022[REDACTED]73:assumed-role/AW[REDACTED]bc1/mo[REDACTED]m"
    }
    ```

If these steps are done we can continue.

## Our First Terraform Run!

**Step 6.** The first thing we need to do is download terraform modules, we will also want to validate the items in our current Lab1. We can do this using the `terraform validate` command.

    ```
    terraform validate
    ```

We get no errors, everything appears great! Our terraform validates. Now let's open the vpc.tf file.

    ```
    nano vpc.tf
    ```

**Step 7.** Let's add the following logic into the VPC file which will create a VPC (Virtual Private Cloud). This will contain the network and the components required to have virtual machines operate

    ```
    resource "aws_vpc" "main" {
        cidr_block = "10.0.0.0/16"
    }
    ```

**Step 8.** What we are doing here is creating a VPC Resource, the name of the Resource (which is only relevant to terraform) is called "main". The only item that we are setting is:

    `cidr_block = "10.0.0.0/16"`

**Step 9.** Let's run `terraform validate` to ensure things will operate correctly.

    ```
    terraform validate
    ```

As you can see we are not operating correctly. 


    ```
    │ Error: Reference to undeclared input variable
    │ 
    │   on provider.tf line 13, in provider "aws":
    │   13:   region = var.region
    │ 
    │ An input variable with the name "region" has not been declared. This variable can be declared with a variable "region" {} block.
    ╵
    ```

The issue here is that in our original provider.tf file the "region" is not filled in. 

**Step 10.** Let's go ahead and create a region variable to help us correct things. 

    ```
    nano vars.tf
    ```

If you have your own AWS account you are free to choose the appropriate region for yourself. If you are given an account then look at the region assigned to you. In the example below it's us-east-1 but this is just an example, it's not real. 

    ```
    variable "region" {
        type        = string
        description = "Please what Datacenter you wish to use, such as us-east-1"
        default     = "us-test-1"
    }
    ```

**Step 11.** Once you save the file, we can run `terraform validate` and it should work.

    ```
    terraform validate
    ```

It should give you this message.

    ```
    Success! The configuration is valid.    
    ```

**Step 12.** Let's now run the following command:

    ```
    terraform plan -out run.plan
    ```
    
The output displayed below should also be of note, look them over first. 


    ```
    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
    symbols:
    + create

    Terraform will perform the following actions:

    # aws_vpc.main will be created
    + resource "aws_vpc" "main" {
        + arn                                  = (known after apply)
        + cidr_block                           = "10.0.0.0/16"
        + default_network_acl_id               = (known after apply)
        + default_route_table_id               = (known after apply)
        + default_security_group_id            = (known after apply)
        + dhcp_options_id                      = (known after apply)
        + enable_dns_hostnames                 = (known after apply)
        + enable_dns_support                   = true
        + enable_network_address_usage_metrics = (known after apply)
        + id                                   = (known after apply)
        + instance_tenancy                     = "default"
        + ipv6_association_id                  = (known after apply)
        + ipv6_cidr_block                      = (known after apply)
        + ipv6_cidr_block_network_border_group = (known after apply)
        + main_route_table_id                  = (known after apply)
        + owner_id                             = (known after apply)
        + tags_all                             = (known after apply)
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Saved the plan to: /tmp/run.plan

    To perform exactly these actions, run the following command to apply:
    terraform apply "run.plan"
    ```

A few things. To note.

1. These items can all be manipulated, for example, dhcp_options_id can be set to a DHCP Options ID Number. This can be pulled in statically or as a data object. 
2. Notice that you have a Plan output below, 1 item to add, 0 to change
3. Finally you can run execute this plan by running: `terraform apply "run.plan"`

**Step 13.** Next, you can apply the terraform:

    ```
    terraform apply "run.plan"
    ```

Hopefully you see the following output below 

    ```
    aws_vpc.main: Creating...
    aws_vpc.main: Creation complete after 1s [id=vpc-0f2f9cc1c8ebd7347]

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    ```

We now have a created resource. We can see this resource in AWS. There are a few ways that we can view it. 

1. We can use `terraform show`
2. We can use `terraform output`

The problem with using terraform output is we have specified no outputs. Let's skip that idea for now. What does `terraform show` do? It allows us to inspect every resource in it's full scope that is in the state file.

Run the following command to see it:

    ```
    terraform show
    ```

The output should be similar to:

    ```
    # aws_vpc.main:
    resource "aws_vpc" "main" {
        arn                                  = "arn:aws:ec2:us-east-1:[redacted]]:vpc/vpc-0d86541f771f258c1"
        assign_generated_ipv6_cidr_block     = false
        cidr_block                           = "10.0.0.0/16"
        default_network_acl_id               = "acl-00ec4fc28abfcb1d6"
        default_route_table_id               = "rtb-0f3426a904b3fa90a"
        default_security_group_id            = "sg-0b36c67520c216a8d"
        dhcp_options_id                      = "dopt-bad978c0"
        enable_dns_hostnames                 = false
        enable_dns_support                   = true
        enable_network_address_usage_metrics = false
        id                                   = "vpc-0d86541f771f258c1"
        instance_tenancy                     = "default"
        ipv6_association_id                  = null
        ipv6_cidr_block                      = null
        ipv6_cidr_block_network_border_group = null
        ipv6_ipam_pool_id                    = null
        ipv6_netmask_length                  = 0
        main_route_table_id                  = "rtb-0f3426a904b3fa90a"
        owner_id                             = "170441420683"
        tags_all                             = {}
    }
    ```

**Step 14.** We can use each one of these items in other resources. Looking at these values at the top:

    ```
    # aws_vpc.main:
    resource "aws_vpc" "main" {
    ```

If we want to insert this value `"vpc-0d86541f771f258c1"` into a *different* resource let's talk about a few things. First, we want to look for the value in the output:

    ```
    id                                   = "vpc-0d86541f771f258c1"
    ```

To leverage these values we could call it by calling `aws_vpc.main.id`, which would replace the the string and insert the vpc- value in the output. We will be using this in a future part of this lab. Let's continue.

**Step 15.** Let's now run `terraform destroy`.

    ```
    terraform destroy
    aws_vpc.main: Refreshing state... [id=vpc-0f2f9cc1c8ebd7347]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    - destroy

    Terraform will perform the following actions:

    # aws_vpc.main will be destroyed
    - resource "aws_vpc" "main" {
        - arn                                  = "arn:aws:ec2:us-east-1:[redacted]:vpc/vpc-0f2f9cc1c8ebd7347" -> null
        - assign_generated_ipv6_cidr_block     = false -> null
        - cidr_block                           = "10.0.0.0/16" -> null
        - default_network_acl_id               = "acl-0b1fe86cf986fdbd5" -> null
        - default_route_table_id               = "rtb-05d0d82807d58bc88" -> null
        - default_security_group_id            = "sg-0ed60e9c328176dd8" -> null
        - dhcp_options_id                      = "dopt-05b58dc3d2a6e6e80" -> null
        - enable_dns_hostnames                 = false -> null
        - enable_dns_support                   = true -> null
        - enable_network_address_usage_metrics = false -> null
        - id                                   = "vpc-0f2f9cc1c8ebd7347" -> null
        - instance_tenancy                     = "default" -> null
        - ipv6_netmask_length                  = 0 -> null
        - main_route_table_id                  = "rtb-05d0d82807d58bc88" -> null
        - owner_id                             = "022499029073" -> null
        - tags                                 = {} -> null
        - tags_all                             = {} -> null
            # (4 unchanged attributes hidden)
        }

    Plan: 0 to add, 0 to change, 1 to destroy.

    Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes
    ```

Please make sure you type yes in the string to destroy all items.

    ```
    aws_vpc.main: Destroying... [id=vpc-0f2f9cc1c8ebd7347]
    aws_vpc.main: Destruction complete after 0s

    Destroy complete! Resources: 1 destroyed.
    ```

## We are now done with Lab 1 please proceed to the Lab 2 directory