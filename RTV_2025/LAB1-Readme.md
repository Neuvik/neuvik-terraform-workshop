# Welcome to Lab 1 - Getting Started with Terraform and Cursor IDE

Welcome to your first Terraform lab! In this lab, you'll learn the fundamentals of Infrastructure as Code (IaC) using Terraform with the **Cursor IDE**. You'll create your first AWS resource and understand the basic Terraform workflow.

## Prerequisites

To get started, you'll need one of the following:

1. **AWS Account**: Lucky enough to be one of the first few that we can provide an account
2. **Existing AWS Account**: Have your own AWS account ready

## Required Tools

Before we begin, ensure you have the following installed:

1. **[Terraform](https://developer.hashicorp.com/terraform/install)** version 1.9.0 or higher
2. **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** version 2
3. **AWS Access Keys** on your local system OR use AWS CloudShell
4. **[Cursor IDE](https://cursor.sh/)** - Our recommended development environment

## Setting Up Your Environment

### Option 1: Local Development with Cursor IDE (Recommended)

**Step 1.** Open Cursor IDE and clone the workshop repository:

```bash
git clone https://github.com/neuvik/neuvik-terraform-workshop
```

**Step 2.** Navigate to the Lab1 directory in Cursor IDE:

```bash
cd neuvik-terraform-workshop/RTV_2025/Lab1
```

You can use Cursor IDE's file explorer on the left to navigate to the `Lab1` folder, or use the integrated terminal (Ctrl/Cmd + `) to run the command above.

**Step 3.** Configure your AWS credentials. In Cursor IDE's integrated terminal, run:

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, default region, and output format when prompted.

### Option 2: AWS CloudShell

For those using AWS CloudShell (which we also recommend), follow these steps:

**Step 1.** Log into AWS Console.

**Step 2.** Open CloudShell from the AWS Console.

**Step 3.** In CloudShell, run the following commands:

```bash
git clone https://github.com/neuvik/neuvik-terraform-workshop
```

```bash
cd neuvik-terraform-workshop/RTV_2025/Lab1
```

```bash
bash quickstart.sh
```

**Step 4.** You'll now have Terraform installed. Since you're using CloudShell, you'll need to use one of the console text editors: `nano`, `vi`, or `emacs`. We'll use `nano` for simplicity.

## Verifying Your Setup

**Step 4.** Let's verify your AWS credentials are working. In Cursor IDE's integrated terminal (or CloudShell), run:

```bash
aws sts get-caller-identity
```

You should see output similar to:

```json
{
  "UserId": "AROA[REDACTED]F:mo[REDACTED]m",
  "Account": "02[REDACTED]73",
  "Arn": "arn:aws:sts::022[REDACTED]73:assumed-role/AW[REDACTED]bc1/mo[REDACTED]m"
}
```

If you see this output, your AWS credentials are properly configured!

## Your First Terraform Configuration

**Step 5.** Let's start by validating our initial Terraform configuration. In Cursor IDE's integrated terminal:

```bash
terraform validate
```

You should see:
```
Success! The configuration is valid.
```

Great! Our initial configuration is valid. Now let's examine the existing files.

**Step 6.** In Cursor IDE, open the `vpc.tf` file:

- Double-click the file in the file explorer
- Or use `Ctrl/Cmd + P` and type "vpc.tf"
- Or right-click the file and select "Open"

You'll see that the file is currently empty. Let's add our first Terraform resource!

**Step 7.** In Cursor IDE, add the following code to `vpc.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

This creates a VPC (Virtual Private Cloud) resource. Let's break down what this means:

- `resource`: Declares a Terraform resource
- `"aws_vpc"`: The resource type (AWS VPC)
- `"main"`: The resource name (used internally by Terraform)
- `cidr_block`: The IP address range for the VPC (10.0.0.0/16 = 65,536 IP addresses)

**Step 8.** Save the file (`Ctrl/Cmd + S`) and validate again:

```bash
terraform validate
```

You might see an error about a missing region variable. This is expected!

## Fixing the Region Variable

**Step 9.** The error occurs because our `provider.tf` file references a region variable that hasn't been defined. Let's create a variables file. In Cursor IDE:

- Right-click in the file explorer and select "New File"
- Name it `vars.tf`
- Or use `Ctrl/Cmd + N` to create a new file and save it as `vars.tf`

**Step 10.** Add the following content to `vars.tf`:

```hcl
variable "region" {
  type        = string
  description = "AWS region to deploy resources (e.g., us-east-1)"
  default     = "us-east-1"
}
```

**Note**: If you have your own AWS account, you can change the default region to any region you prefer. If you're using a provided account, use the region assigned to you.

**Step 11.** Save the file and validate again:

```bash
terraform validate
```

You should now see:
```
Success! The configuration is valid.
```

Excellent! Our configuration is now valid.

## Planning Your Infrastructure

**Step 12.** Now let's see what Terraform plans to create. In Cursor IDE's integrated terminal:

```bash
terraform plan -out run.plan
```

This command:
- Analyzes your configuration
- Compares it with the current state
- Creates an execution plan
- Saves the plan to a file called `run.plan`

You should see output similar to:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
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

Key points from this output:
- **`+ create`**: Terraform will create 1 new resource
- **`Plan: 1 to add, 0 to change, 0 to destroy`**: Summary of planned actions
- **`(known after apply)`**: Values that will be determined when the resource is created

## Applying Your Configuration

**Step 13.** Now let's create the VPC! In Cursor IDE's integrated terminal:

```bash
terraform apply "run.plan"
```

You should see output similar to:

```
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 1s [id=vpc-0f2f9cc1c8ebd7347]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Congratulations! You've successfully created your first AWS resource using Terraform! 🎉

## Inspecting Your Resources

**Step 14.** Let's examine the created resource. In Cursor IDE's integrated terminal:

```bash
terraform show
```

This command shows detailed information about all resources in your Terraform state. You should see output similar to:

```
# aws_vpc.main:
resource "aws_vpc" "main" {
    arn                                  = "arn:aws:ec2:us-east-1:[redacted]:vpc/vpc-0d86541f771f258c1"
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

## Understanding Resource References

**Step 15.** Notice the `id` field in the output: `"vpc-0d86541f771f258c1"`. This is the VPC ID that AWS assigned.

In Terraform, you can reference this value in other resources using:
- `aws_vpc.main.id` - References the VPC ID
- `aws_vpc.main.arn` - References the VPC ARN
- `aws_vpc.main.cidr_block` - References the VPC CIDR block

This is how Terraform resources can reference each other, which we'll explore in future labs.

## Cleaning Up

**Step 16.** Finally, let's clean up our resources to avoid unnecessary AWS charges. In Cursor IDE's integrated terminal:

```bash
terraform destroy
```

You'll see a plan showing what will be destroyed:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
- destroy

Terraform will perform the following actions:

# aws_vpc.main will be destroyed
- resource "aws_vpc" "main" {
    - arn                                  = "arn:aws:ec2:us-east-1:[redacted]:vpc/vpc-0f2f9cc1c8ebd7347" -> null
    - assign_generated_ipv6_cidr_block     = false -> null
    - cidr_block                           = "10.0.0.0/16" -> null
    # ... more fields ...
}

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
Terraform will destroy all your managed infrastructure, as shown above.
There is no undo. Only 'yes' will be accepted to confirm.

Enter a value: yes
```

Type `yes` to confirm the destruction.

You should see:
```
aws_vpc.main: Destroying... [id=vpc-0f2f9cc1c8ebd7347]
aws_vpc.main: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

## Cursor IDE Tips for Terraform Development

1. **Syntax Highlighting**: Cursor IDE provides excellent Terraform syntax highlighting
2. **IntelliSense**: Get autocomplete suggestions for resource types and attributes
3. **Error Detection**: Real-time error checking for syntax issues
4. **Integrated Terminal**: Run Terraform commands without leaving the IDE
5. **File Explorer**: Easy navigation between Terraform files
6. **Multi-cursor Editing**: Edit multiple similar lines simultaneously
7. **Search and Replace**: Use `Ctrl/Cmd + F` for quick text searches

## What You've Learned

In this lab, you've successfully:

✅ **Set up your development environment** with Cursor IDE and Terraform  
✅ **Created your first AWS resource** (a VPC) using Infrastructure as Code  
✅ **Understood the Terraform workflow**: validate → plan → apply → destroy  
✅ **Learned about resource references** and how Terraform manages state  
✅ **Used Cursor IDE features** for efficient Terraform development  

## Next Steps

You're now ready to proceed to **Lab 2**, where you'll build more complex infrastructure including subnets, security groups, and EC2 instances!

Navigate to the Lab2 directory:
```bash
cd ../Lab2
```

---

**Congratulations on completing Lab 1!** You've taken your first steps into the world of Infrastructure as Code with Terraform and Cursor IDE. 🚀