output "vpc_id" {
    value = aws_vpc.this.id
}


output "public_subnet_id" {
    value = aws_subnet.public_subnet.id
}