# First, require the latest providers for terraform, specifically we are going use the AWS Provider, and a version of 5.0 or greater.
terraform {
  required_providers { }
}

# Configure this provider to the region that you are assigned. By default we are going ot use us-east-1.
provider "aws" { }