output "vpc_id" {
  value = aws_vpc.basic-infra.id
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private-subnet.id
}

output "ec2_private_ip" {
  value = aws_instance.basic-infra-ec2.private_ip
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat-gateway.public_ip
}
