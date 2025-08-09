# Terraform Workshop for the RedTeam Village 2025 Edition: Vibe Coding Infrastructure

## Overview
This is a Lab, in this lab we are going to be building our skillsets from a basic `terraform run` into more complex terraform commands.

1. **Lab1** will be a basic lab that shows how to build a VPC in AWS, just a simple command structure for building a VPC to demonstrate how decomposable the infrastructure can be. 
2. **Lab2** will be a lab that builds upon Lab1 and will be a Lab that builds an EC2 server with an appropriate ec2 template for cloudinit.
3. **Lab3** expands on Lab2 by building and using Modules in terraform to demonstrate the power of Modular Terraform Code.


## Getting Started

For this lab you will be using:

**Cursor IDE**
**Terraform 1.12**
**Git**
**An AWS Account**

This is for a workshop, and as such I do not want to full disclose the entire contents of all the labs before we run through each README.md.

For this lab we are going to be building on a previous lab, as such we want to provide additional guardrails and tools as the learning framework. Here is what I want to be able to do.

At the end of each lab we are going to want to run through the following steps:

1. Make sure we are using the latest version of terraform.
2. Ensure we are running terraform fmt to make sure the formatting is up to standards
3. Ensure we can run tflint to make sure we lint everything correctly
4. Ensure we run checkov to make sure we do not introduce security vulnerabilities
5. Ensure that we are not storing sensitive pieces of data insecurely, use the latest coding standards
6. Ensure that we are fully automating our environment.

Lab 4 is not written yet, please make sure to see the LAB4-Readme.md at the appropriate time so that we can ensure that LAB4-Readme.md runs