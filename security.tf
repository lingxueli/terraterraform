resource "aws_security_group" "ec2_allow" {
  name        = "ec2_allow"
  description = "ec2 allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "inbound from public subnet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public1.cidr_block, aws_subnet.public2.cidr_block, "73.181.104.164/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow"
  }
}