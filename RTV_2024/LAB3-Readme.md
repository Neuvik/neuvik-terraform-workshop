# Welcome to Lab 3

We are now going to go into a more advanced lab. Modules. Modules can help us scale out the number of hosts by allowing us to "modularize" further some of the tasks we do.

What if we wanted to build:

1. A Bastion Host that accepts SSH Inbound
2. A C2 Server 
3. More than one Server

But we didn't want to keep writing the same terraform modules? What if we could make it into a module?

Let's start like we did before but now we are going to have a VPC module for networking.

## Getting started with VPCs

**Step 1.** Let's next move into building a few systems, to do this we will need at a minimum a VPC. 


  ```
  cd ../Lab3
  ```


Now, let's try and unwind what is needed for a module we have to look at what the module expects. This can be a bit difficult if we have not defined the variables needed for our module to build. Now let's start with the first question. WHY? Why are we doing a module? Well let's consider the following scenario:

1. You want to produce a configuration that is not tied to a single region
2. You do not want to write the same code over and over again
3. You want the same results, however.

To do this, you will need to best understand the way the module is structured. In many cases, modules are documented but in our case, it is not. Do you give up? No. Let's start with the VPC Module. This one is located here:

  ```
  cd ./modules/networking/
  ```

From the current directory it is two directories in. It has 3 files. 

1. main.tf: This is the main module with all of the VPC items
2. vars.tf: In this case, you need to provide the module with the variables in here, this is where to look
3. output.tf: This is the output from the module that you can use in *OTHER* places

Now let's see how to build this. 

**Step 2**. Look at the following:

  ```
  cat ./modules/networking/vars.tf
  ```

You will notice **A LOT** of variables in the system, so let's build a vars.tf that will match these variables and allow us to use the variables.

  ```
  nano vars.tf
  ```

**Step 3.** Here is how we begin. Start by adding the following statement:

  ```
  module "vpc_network" {
     source = "./modules/networking"
  }
  ```
  
This is a blank statement that tells terraform, we are going to use a module called "vpc_network" and we are going to find that module in this path. Now what we are going to need to do is within the {} start adding our variables. Let's use variables of our own. Make the file look like this:

  ```
  module "vpc_network" {
    source = "../modules/networking"

    vpc_block                       = var.cidr_block_east                 # This is the Supernet that contains all your subnet, default = "10.0.0.0/16"
    vpcname                         = var.vpc_name                        # This is the name of the VPC
    vpcdescription                  = var.vpc_description                 # This is a description tag for it
    public_subnet                   = var.public_subnet                   # This is the public subnet range which the default = "10.0.0.0/24"
    public_subnet_name              = var.public_subnet_name              # This is the public subnet name, default is "public-subnet"
    public_subnet_description       = var.public_subnet_description       # This is the public subnet description, default is "public subnet"
    region                          = var.region                          # This is the region, default is us-east-1, like the rest of the world.
    private_subnet                  = var.private_subnet                  # This is the private subnet range, which the default is = "10.0.1.0/24"
    private_subnet_name             = var.private_subnet_name             # This is the private subnet name, default is "private-subnet"
    private_subnet_description      = var.private_subnet_description      # This is the private subnet description, the default is private subnet
    public_route_table_name         = var.public_route_table_name         # This is the name of the Route Table, default is "public-route-table"
    public_route_table_description  = var.public_route_table_description  # This is the description of the Route Table, default is "Public Route Table"
    igw_name                        = var.igw_name                        # This is the name of the Internet Gateway, default is "internet-gateway"
    igw_description                 = var.igw_description                 # This is the description of the Internet Gateway, default is "Internet Gateway"
    natgw_name                      = var.natgw_name                      # This is the name of the Internet Gateway, default is "nat-gateway"
    natgw_description               = var.natgw_description               #This is the description of the Internet Gateway, default is "NAT Gateway"
    private_route_table_name        = var.private_route_table_name        # This is the name of the Route Table, default is "private-route-table"
    private_route_table_description = var.private_route_table_description # This is the description of the Route Table, default is "Private Route Table"
    create_nat_gateway              = var.create_nat_gateway              # This instructs the system to create a NAT gateway for private subnets
    az                              = var.az                              # Availability zone such as "a" for each datacenter, default is "a"
  }
  ```

  Copy and paste is probably your friend, but you can see what we have done here is added a bunch of variables that we will be using in our next step. Do you see this:

  ```
  vpc_block                       = var.cidr_block_east
  ```

  This is very useful as a module to allow us to take a a variable we define and inserting it in this VPC block. 


**Step 4.**  Next, let's create a file called `vars.tf`

  ```
  nano vars.tf
  ```

Within vars.tf we will need to now insert a bunch of variables that we will use to configure each of the building blocks. Notice that I gave some of the names in this example the name of "east". What if we wanted to have one module reference the "East" (us-east-1) vs "West". We could do this in different statefiles or the same one and reference the modules to allow us modularity in our runs. 

  ```
  #The variable below allows you to chose an AWS DataCenter such as "us-east-1"
  variable "region" {
    type        = string
    description = "Please what Datacenter you wish to use, such as us-east-1"
  }

  variable "cidr_block_east" {
    type        = string
    description = "Supernet Block for AWS"
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

  variable "public_subnet" {
    type        = string
    description = "Public Subnet"
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

  variable "private_subnet" {
    type        = string
    description = "Public Subnet"
    default     = "10.0.1.0/24"
  }

  variable "private_subnet_name" {
    type        = string
    description = "Private Subnet Name"
    default     = "private-subnet"
  }

  variable "private_subnet_description" {
    type        = string
    description = "Public Subnet Description"
    default     = "public-subnet"
  }

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
    description = "Internet Gateway Description"
    default     = "Internet Gateway"
  }

  variable "private_route_table_name" {
    type        = string
    description = "private Route Table Name"
    default     = "private-route-table"
  }

  variable "private_route_table_description" {
    type        = string
    description = "private Route Table Description"
    default     = "Private Route Table"
  }

  variable "create_nat_gateway" {
    type        = bool
    description = "Create NAT Gateway"
    default     = false
  }

  variable "az" {
    type        = string
    description = "What Availability Zone"
    default     = "a"
  }
  ```

**Step 6.** Now comes the moment of truth, will this terraform work?

  ```
  terraform init
  ```

  ```
  terraform apply
  ```

Notice this error:

  ```
  Plan: 6 to add, 0 to change, 0 to destroy.
  ╷
  │ Error: Invalid index
  │ 
  │   on modules/networking/output.tf line 6, in output "private_route_table_id":
  │    6:     value = aws_route_table.private[0].id
  │     ├────────────────
  │     │ aws_route_table.private is empty tuple
  │ 
  │ The given key does not identify an element in this collection value: the collection has no elements.
  ╵
  ╷
  │ Error: Invalid index
  │ 
  │   on modules/networking/output.tf line 10, in output "private_subnet_id":
  │   10:     value = aws_subnet.private_subnet[0].id
  │     ├────────────────
  │     │ aws_subnet.private_subnet is empty tuple
  │ 
  │ The given key does not identify an element in this collection value: the collection has no elements.
  ╵
  ```

This was left here to explain count and different ways to build modules. One of the tricks we are using to build a module lies here:

  ```
  resource "aws_subnet" "private_subnet" {
    count             = var.create_private_subnet ? 1 : 0
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.private_subnet
    availability_zone = "${var.region}${var.az}"

    tags = {
      Name        = var.private_subnet_name
     Description = var.private_subnet_description
   }
  }
  ```

There is a line called 

  ```
  count             = var.create_private_subnet ? 1 : 0
  ```
  
This is a bit of a trick to build the module. What this is a terraform conditional expression. It almost looks like a ternary operator in C++ and somewhat acts like one. But it's a bit different. What its saying is that it will set the count (number of devices) to 1 unless 0 is set. In this case its evaluating 1 and 0 as true and false. Well once we use the count in terraform we are forced to declare the index number of our count. Because we are using a single resource (either true or false), we will use the first index for each of the private subnets we are calling. For example

  ```
  create_private_subnet[0]
  ```

Ok so if we look at this statement:

  ```
  subnet_id      = aws_subnet.private_subnet[0].id
  ```

You can see that every time we reference aws_subnet.private_subnet it is using [0] for the first one. And we can then later use this pattern to define 1..N (many) number of servers or resources. But for now. Let's concentrate on our problem fixing:

  ```
  on modules/networking/output.tf line 6, in output "private_route_table_id":
  │    6:     value = aws_route_table.private[0].id
  │     ├────────────────
  │     │ aws_route_table.private is empty tuple
  ```

To fix this we need to look at what is happening. We are *NOT* building a private subnet or have a private routing table, so when the output tries to run on *optional* values it fails. How can we satisfy this? Well we can use this pattern:

  ```
  try(aws_route_table.private[0].id, null)
  ```

**Step 7.** So the solution here is to perform the following task

  ```
  nano ./modules/networking/output.tf
  ```

  Look for the following lines:

  ```
  output "private_route_table_id" {
    value = aws_route_table.private[0].id
  }

  output "private_subnet_id" {
    value = aws_subnet.private_subnet[0].id
  }
  ```

Make them look like:

  ```
  output "private_route_table_id" {
    value = try(aws_route_table.private[0].id, null)
  }

  output "private_subnet_id" {
    value = try(aws_subnet.private_subnet[0].id , null)
  }

  ```

**Step 7.** Now how can modularize EC2 Servers? Well let's look at how those EC2 servers will work. The first one that we are going to use is the C2 Server (which is the sliver server). Let's create a module starting the wording of "sliver"

  ```
  nano ec2.tf
  ```

  Let's review what we will need for the module.

1. Subnet ID: This comes from the VPC run, how do we call it? We can use the following nomenclature: `module.vpc_network.public_subnet_id`. Now why is thiss? Becuase we are using our sliver_c2 module and it has an output variable defined to emit the public_subnet_id. 
2. Then IP Address of the Sliver Server as well as the NIC Name
3. We want to provide an assessment name
4. We want to provide a server name
5. We don't care about destroying the server so the lifetime of the server will be set to false, we can destroy it with terraform.
6. We want a list of internal users as a map, will discuss this in a minute
7. We want User Data
8. We want a custom set of commands to run, such as setting the hostname or setting the sliver commands. 

  ```
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

This will build our module more or less, we have intermixed variables and names just to show you that it can be either or, depending on abstraction and preference.

Next let's APPEND to our vars.tf

  ```
  variable "sliver_c2_ip" {
    default = "10.0.0.20"
  }
  ```

  ```
  variable "sliver_c2_nic_name" {
    default = "SLIVER-C2-NIC0"
  }
  ```

  ```
  variable "operators" {
    type = map(any)
    default = {
      "operator" = "SSH-Key Here!",
      "operator2" = "Same SSH-Key!"
    }
  }
  ```

  ```
  variable "sliver_commands" {
    type = map(any)
      default = {
        command_one   = "curl https://sliver.sh/install|sudo bash",
        command_two   = "systemctl daemon-reload",
        command_three = "systemctl enable sliver"
    }
  }
  ```

Now we can chose to build ANOTHER server if we wish. Because we have modularzied this we can rebuild our SSH Bastion as an example, but instead I wanted to show you how to build an NGINX server with a custom set of variables.

  ```
  nano ec2.tf
  ```

Let's APPEND the following

  ```
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
    server_name            = "SSH-HOST"
    prevent_destroy        = false
    user_data              = true
    assessment             = "RedTeamVillage"
    commands               = var.bastion_commands
  }
  ```

To the vars.tf file we will also need to append a few other commands:

  ```
  variable "bastion_ip" {
    default = "10.0.0.20"
  }
  ```

  ```
  variable "bastion_nic_name" {
    default = "BASTION-NIC0"
  }
  ```

  ```
  variable "operators" {
    type = map(any)
    default = {
      "operator" = "SSH-Key Here!",
      "operator2" = "Same SSH-Key!"
    }
  }
  ```

  ```
  variable "bastion_commands" {
    type = map(any)
      default = {
        command_one   = "hostnamectl set-hostname bastion"
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

You have no built modularized servers with a modularized network. You can see the power in the language is you wish to continue to use it. We use this for all of our terraform runs and we can easily build and destroy systems. This includes:

- Storing configurations in S3
- Building out Cobalt Strike
- Setting up Gophish and Evilginx

Before you are done please run:

  ```
  terraform destroy -auto-approve
  ```


Thank you!

