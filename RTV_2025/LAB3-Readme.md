# Welcome to Lab 3 - Terraform Modules with Cursor IDE

We are now going to go into a more advanced lab using **Terraform Modules** with the **Cursor IDE**. This lab will demonstrate how to scale out infrastructure by creating reusable, modular components that can be used across different environments.

## What We'll Build

In this lab, we'll create a modular infrastructure that can support:

1. **A Bastion Host** that accepts SSH connections
2. **A C2 Server** (Sliver) for command and control operations
3. **Multiple servers** using the same modular approach

The beauty of modules is that we don't have to write the same Terraform code repeatedly. Instead, we create reusable modules that can be configured with different parameters.

## Getting Started with Cursor IDE

**Step 1.** Open Cursor IDE and navigate to the Lab3 directory:

```bash
cd ../Lab3
```

In Cursor IDE, you can use the file explorer on the left to navigate to the `Lab3` folder, or use the integrated terminal (Ctrl/Cmd + `) to run the command above.

## Understanding Terraform Modules

Before we dive in, let's understand **why** we use modules:

1. **Region Independence**: Create configurations that work across different AWS regions
2. **Code Reusability**: Avoid writing the same infrastructure code repeatedly
3. **Consistency**: Ensure the same results across different environments

## Exploring the VPC Module

**Step 2.** Let's examine the VPC module structure. In Cursor IDE, navigate to the modules directory:

```
./modules/networking/
```

You can use the file explorer to browse this directory, or use the integrated terminal:

```bash
ls ./modules/networking/
```

The VPC module contains three essential files:

1. **`main.tf`**: Contains the main VPC infrastructure resources
2. **`vars.tf`**: Defines all the input variables the module expects
3. **`output.tf`**: Specifies what values the module exports for use elsewhere

**Step 3.** Let's examine the module's variables. In Cursor IDE, open the file:

```
./modules/networking/vars.tf
```

You can do this by:
- Double-clicking the file in the file explorer
- Using `Ctrl/Cmd + P` and typing the filename
- Right-clicking the file and selecting "Open"

You'll notice there are **many variables** defined. This is what makes the module flexible and reusable.

## Creating the VPC Module Configuration

**Step 4.** Now let's create our main configuration. In Cursor IDE, create a new file called `vpc.tf`:

- Right-click in the file explorer and select "New File"
- Name it `vpc.tf`
- Or use `Ctrl/Cmd + N` to create a new file and save it as `vpc.tf`

Start by adding the basic module declaration:

```hcl
module "vpc_network" {
  source = "./modules/networking"
}
```

This tells Terraform we want to use a module called "vpc_network" from the specified path.

**Step 5.** Now let's add all the required variables. In Cursor IDE, you can use the multi-cursor feature (`Alt + Click` or `Ctrl/Cmd + Alt + Up/Down`) to edit multiple lines simultaneously. Replace the content with:

```hcl
module "vpc_network" {
  source = "./modules/networking"

  vpc_block                       = var.cidr_block_east                 # Supernet containing all subnets, default = "10.0.0.0/16"
  vpcname                         = var.vpc_name                        # VPC name
  vpcdescription                  = var.vpc_description                 # Description tag
  public_subnet                   = var.public_subnet                   # Public subnet range, default = "10.0.0.0/24"
  public_subnet_name              = var.public_subnet_name              # Public subnet name, default = "public-subnet"
  public_subnet_description       = var.public_subnet_description       # Public subnet description
  region                          = var.region                          # AWS region, default = us-east-1
  private_subnet                  = var.private_subnet                  # Private subnet range, default = "10.0.1.0/24"
  private_subnet_name             = var.private_subnet_name             # Private subnet name, default = "private-subnet"
  private_subnet_description      = var.private_subnet_description      # Private subnet description
  public_route_table_name         = var.public_route_table_name         # Route table name, default = "public-route-table"
  public_route_table_description  = var.public_route_table_description  # Route table description
  igw_name                        = var.igw_name                        # Internet Gateway name, default = "internet-gateway"
  igw_description                 = var.igw_description                 # Internet Gateway description
  natgw_name                      = var.natgw_name                      # NAT Gateway name, default = "nat-gateway"
  natgw_description               = var.natgw_description               # NAT Gateway description
  private_route_table_name        = var.private_route_table_name        # Private route table name
  private_route_table_description = var.private_route_table_description # Private route table description
  create_nat_gateway              = var.create_nat_gateway              # Create NAT gateway for private subnets
  az                              = var.az                              # Availability zone, default = "a"
}
```

Notice how we're using variables like `var.cidr_block_east`. This allows us to define these values in a separate file and reuse the module with different configurations.

## Creating the Variables File

**Step 6.** Now let's create the `vars.tf` file. In Cursor IDE:

- Create a new file called `vars.tf`
- We'll define all the variables that our module references

The naming convention with "east" is strategic - it allows us to create different configurations for different regions (e.g., "east" for us-east-1, "west" for us-west-2).

```hcl
# AWS Region selection
variable "region" {
  type        = string
  description = "AWS region to deploy resources (e.g., us-east-1)"
}

# VPC Configuration
variable "cidr_block_east" {
  type        = string
  description = "Supernet block for AWS VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "main-vpc"
}

variable "vpc_description" {
  type        = string
  description = "VPC Description"
  default     = "Main VPC"
}

# Public Subnet Configuration
variable "public_subnet" {
  type        = string
  description = "Public Subnet CIDR"
  default     = "10.0.0.0/24"
}

variable "public_subnet_name" {
  type        = string
  description = "Public Subnet Name"
  default     = "public-subnet"
}

variable "public_subnet_description" {
  type        = string
  description = "Public Subnet Description"
  default     = "Public Subnet"
}

# Private Subnet Configuration
variable "private_subnet" {
  type        = string
  description = "Private Subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  type        = string
  description = "Private Subnet Name"
  default     = "private-subnet"
}

variable "private_subnet_description" {
  type        = string
  description = "Private Subnet Description"
  default     = "Private Subnet"
}

# Route Table Configuration
variable "public_route_table_name" {
  type        = string
  description = "Public Route Table Name"
  default     = "public-route-table"
}

variable "public_route_table_description" {
  type        = string
  description = "Public Route Table Description"
  default     = "Public Route Table"
}

variable "private_route_table_name" {
  type        = string
  description = "Private Route Table Name"
  default     = "private-route-table"
}

variable "private_route_table_description" {
  type        = string
  description = "Private Route Table Description"
  default     = "Private Route Table"
}

# Gateway Configuration
variable "igw_name" {
  type        = string
  description = "Internet Gateway Name"
  default     = "internet-gateway"
}

variable "igw_description" {
  type        = string
  description = "Internet Gateway Description"
  default     = "Internet Gateway"
}

variable "natgw_name" {
  type        = string
  description = "NAT Gateway Name"
  default     = "nat-gateway"
}

variable "natgw_description" {
  type        = string
  description = "NAT Gateway Description"
  default     = "NAT Gateway"
}

# Additional Configuration
variable "create_nat_gateway" {
  type        = bool
  description = "Create NAT Gateway for private subnets"
  default     = false
}

variable "az" {
  type        = string
  description = "Availability Zone"
  default     = "a"
}
```

## Testing Our Configuration

**Step 7.** Now let's test our Terraform configuration. In Cursor IDE's integrated terminal:

```bash
terraform init
```

This initializes Terraform and downloads any required providers.

```bash
terraform plan
```

This will show you what Terraform plans to create. You might see some errors related to missing variables - that's expected at this stage.

## Fixing Module Output Issues

**Step 8.** You might encounter an error like this:

```
Error: Invalid index
  on modules/networking/output.tf line 6, in output "private_route_table_id":
   6:     value = aws_route_table.private[0].id
    ├────────────────
    │ aws_route_table.private is empty tuple
```

This error occurs because the module uses **conditional resource creation** with the `count` parameter. Let's examine this pattern:

```hcl
resource "aws_subnet" "private_subnet" {
  count             = var.create_private_subnet ? 1 : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet
  availability_zone = "${var.region}${var.az}"
  # ... other configuration
}
```

The `count = var.create_private_subnet ? 1 : 0` is a **conditional expression** that creates either 1 or 0 resources based on the variable value.

**Step 9.** To fix the output errors, we need to use the `try()` function. In Cursor IDE, open:

```
./modules/networking/output.tf
```

Find these lines:

```hcl
output "private_route_table_id" {
  value = aws_route_table.private[0].id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet[0].id
}
```

Replace them with:

```hcl
output "private_route_table_id" {
  value = try(aws_route_table.private[0].id, null)
}

output "private_subnet_id" {
  value = try(aws_subnet.private_subnet[0].id, null)
}
```

The `try()` function attempts to evaluate the expression and returns `null` if it fails, preventing the error.

## Creating EC2 Server Modules

**Step 10.** Now let's create modular EC2 servers. In Cursor IDE, create a new file called `ec2.tf`.

First, let's create a **Sliver C2 Server**:

```hcl
module "sliver_c2" {
  source = "./modules/servers"

  subnet_id              = module.vpc_network.public_subnet_id
  network_interface_ip   = var.sliver_c2_ip
  network_interface_name = var.sliver_c2_nic_name
  security_group_id      = aws_security_group.main_sg.id
  ami_id                 = data.aws_ami.ubuntu.id
  operators              = var.operators
  instance_type          = "t3.small"
  root_block_size        = 100
  server_name            = "SLIVER-C2"
  prevent_destroy        = false
  user_data              = true
  assessment             = "RedTeamVillage"
  commands               = var.sliver_commands
}
```

**Step 11.** Now let's add the corresponding variables to `vars.tf`. In Cursor IDE, you can use `Ctrl/Cmd + End` to go to the end of the file and append:

```hcl
# Sliver C2 Server Configuration
variable "sliver_c2_ip" {
  type    = string
  default = "10.0.0.20"
}

variable "sliver_c2_nic_name" {
  type    = string
  default = "SLIVER-C2-NIC0"
}

variable "operators" {
  type = map(any)
  default = {
    "operator"  = "SSH-Key Here!",
    "operator2" = "Same SSH-Key!"
  }
}

variable "sliver_commands" {
  type = map(any)
  default = {
    command_one   = "curl https://sliver.sh/install|sudo bash",
    command_two   = "systemctl daemon-reload",
    command_three = "systemctl enable sliver"
  }
}
```

**Step 12.** Let's add a **Bastion Host** as well. In Cursor IDE, open `ec2.tf` and append:

```hcl
module "bastion" {
  source = "./modules/servers"

  subnet_id              = module.vpc_network.public_subnet_id
  network_interface_ip   = var.bastion_ip
  network_interface_name = var.bastion_nic_name
  security_group_id      = aws_security_group.main_sg.id
  ami_id                 = data.aws_ami.ubuntu.id
  operators              = var.operators
  instance_type          = "t3.small"
  root_block_size        = 100
  server_name            = "SSH-BASTION"
  prevent_destroy        = false
  user_data              = true
  assessment             = "RedTeamVillage"
  commands               = var.bastion_commands
}
```

**Step 13.** Add the bastion variables to `vars.tf`:

```hcl
# Bastion Host Configuration
variable "bastion_ip" {
  type    = string
  default = "10.0.0.21"
}

variable "bastion_nic_name" {
  type    = string
  default = "BASTION-NIC0"
}

variable "bastion_commands" {
  type = map(any)
  default = {
    command_one = "hostnamectl set-hostname bastion"
  }
}
```

## Final Steps and Validation

**Step 14.** Now let's validate and apply our configuration. In Cursor IDE's integrated terminal:

```bash
terraform init
```

```bash
terraform fmt
```

This formats your Terraform code for consistency.

```bash
terraform validate
```

This checks for syntax errors and configuration issues.

```bash
terraform plan
```

This shows you exactly what will be created.

```bash
terraform apply
```

This creates all the resources. Type `yes` when prompted.

## Understanding the Power of Modules

You've now built a **modularized infrastructure** with:

- **Reusable VPC module** that can be deployed in different regions
- **Generic server module** that can create any type of EC2 instance
- **Consistent configuration** across all resources

This modular approach enables you to:

- **Scale easily**: Add more servers by simply adding more module calls
- **Maintain consistency**: All servers get the same base configuration
- **Reduce duplication**: Write once, use many times
- **Support different environments**: Use the same modules for dev, staging, and production

## Practical Applications

This modular foundation can be extended for:

- **Cobalt Strike infrastructure** deployment
- **Gophish and Evilginx** phishing setups
- **S3 configuration storage** and management
- **Multi-region deployments** with consistent architecture

## Cleanup

When you're finished, clean up your resources:

```bash
terraform destroy -auto-approve
```

## Cursor IDE Tips for Terraform Development

1. **Syntax Highlighting**: Cursor IDE provides excellent Terraform syntax highlighting
2. **IntelliSense**: Get autocomplete suggestions for resource types and attributes
3. **Error Detection**: Real-time error checking for syntax issues
4. **Integrated Terminal**: Run Terraform commands without leaving the IDE
5. **File Explorer**: Easy navigation between module files
6. **Multi-cursor Editing**: Edit multiple similar lines simultaneously
7. **Search and Replace**: Use `Ctrl/Cmd + F` for quick text searches

## Congratulations!

You've successfully completed Lab 3 and learned how to use Terraform modules with Cursor IDE. You now have the foundation to build scalable, maintainable infrastructure as code!

---

**Next Steps**: Consider exploring advanced module features like:
- Module versioning
- Remote module sources
- Module composition
- Conditional module creation

