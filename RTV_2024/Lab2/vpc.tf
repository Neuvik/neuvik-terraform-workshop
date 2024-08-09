# Remember to use the VPC from the pervious exercise.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
