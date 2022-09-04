resource "aws_instance" "web1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private1.id
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "http_server_1"
  }

  vpc_security_group_ids = [aws_security_group.ec2_allow.id]

  user_data = file("user-data.sh")
}

resource "aws_instance" "web2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private2.id
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "http_server_2"
  }

  vpc_security_group_ids = [aws_security_group.ec2_allow.id]

  user_data = file("user-data.sh")
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC85X2/ssOMbE1TwpNqRuo2n/LIEEcERfvpgkvlLZXFM16JdnnvJf6e3m8f+dUThotfeyWGTfT2W2Iz8bsY2ICrNwW7mHZTH50RxTT7r383EQrAhFCv6+Qlkn91DHPGpuBvtfN3Eo8YnuBQTDUn9VOY9ZiZjDqR5t+EOAlXFGpOGEQkehDmlp82XMV/UEUAzZ58HslIQOsiBx2eTLPR/ubgFPjg9+Nem9rpTtLpbBwg2Ix+qYnP24eFaDDT6FZ3z+Y6woIR5SXO+sQOlE2FOIqWbJ7/7hNkAGXigW+/PdC4E7nz4CoDiTcIBx+2B30Yjserq4eU6BfzHqirKT3lffom4Gvj4kLWg8sQNsf+lrF2yEGuNDUbpCMsyAgLtUtQIBizcI3diSQYEIhJ4BbVY/wAj5hk8KV6Qv7CwmQp79ARG4UaamFOhiXv0sGeq4MyX/nB/pVzLAK1qrOeDRnQmX0hIPFWTh+w0+EaW8bJUxnDKwX2atiy3FQEbiC8WrYPsmc= lisamarie@Lisas-MacBook-Pro.local"
}