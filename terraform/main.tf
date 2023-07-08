provider "aws" {
  region = "us-east-1"  # Update with your desired region
}

resource "aws_vpc" "server_vpc" {
  cidr_block = "137.50.0.0/16"  # Update with your desired VPC CIDR block
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "137.50.0.0/24"  # Update with your desired public subnet CIDR block
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "137.50.1.0/24"  # Update with your desired private subnet CIDR block
  map_public_ip_on_launch = false
}

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.example_vpc.id
  
  # Add any additional inbound or outbound rules as needed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.example_vpc.id
  
  # Add any additional inbound or outbound rules as needed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
}

resource "aws_instance" "public_instance" {
  ami           = "ami-06464c878dbe46da4"  # Update with your desired AMI ID
  instance_type = "t2.micro"      # Update with your desired instance type
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  # User data script to install Ansible
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y ansible
              EOF

  tags = {
    Name = "PublicInstance"
  }
}

resource "aws_instance" "private_instance" {
  ami           = "ami-06464c878dbe46da4"  # Update with your desired AMI ID
  instance_type = "t2.micro"      # Update with your desired instance type
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "PrivateInstance"
  }
}
