# Define the VPC resource
resource "aws_vpc" "devops-priv-vpc" {
  cidr_block = var.KKE_VPC_CIDR

  tags = {
    Name = "devops-priv-vpc"
  }
}

# Create the private subnet
resource "aws_subnet" "devops-priv-subnet" {
  vpc_id                  = aws_vpc.devops-priv-vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  map_public_ip_on_launch = false

  tags = {
    Name = "devops-priv-subnet"
  }
}


# Create the Security Group
resource "aws_security_group" "devops-priv-sg" {
  name        = "devops-priv-sg"
  description = "Security group that only allows traffic inside the VPC"
  vpc_id      = aws_vpc.devops-priv-vpc.id

  ingress {
    description = "Allow all internal VPC traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.KKE_VPC_CIDR]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Provision the EC2 instance
resource "aws_instance" "devops-priv-ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.devops-priv-subnet.id
  vpc_security_group_ids = [aws_security_group.devops-priv-sg.id]

  tags = {
    Name = "devops-priv-ec2"
  }
}