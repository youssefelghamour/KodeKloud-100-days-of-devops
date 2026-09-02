# Day 98: Launch EC2 in Private VPC Subnet Using Terraform

## Objective
The objective is to provision an isolated infrastructure on AWS using Terraform. I created a custom Virtual Private Cloud (VPC) with a private subnet to host an EC2 instance that is completely hidden from the public internet. Access is restricted through security group rules that only allow traffic originating from within the VPC's own network range.

## 1. Private Infrastructure

In a secure cloud environment, sensitive servers should not be exposed to the internet. I implemented several layers of isolation for this task:

### Custom Network Boundary (VPC)
A VPC defines the overall IP address space for the environment. By creating `devops-priv-vpc`, I established a private network segment where I control all routing.

### Network Sub-division (Subnets)
Subnets allow for organizing resources within a VPC. By disabling the `map_public_ip_on_launch` setting, I ensured that any instance launched in the `devops-priv-subnet` does not receive a public IP address. This makes the server unreachable from the outside world by default.

### Internal Traffic Filtering (Security Groups)
The security group acts as an stateful firewall. For this private instance, I configured the inbound rules to only accept traffic from the VPC CIDR block (`10.0.0.0/16`). This means that even if someone manages to find the private IP, they can only connect to the instance if they are already inside the same network.

### Decoupling Logic (Variables and Outputs)
*   **Variables:** I used `variables.tf` to store configuration values like CIDR blocks. This separates the "what" (data) from the "how" (infrastructure logic), making the code easier to maintain.
*   **Outputs:** I used `outputs.tf` to print critical resource information once the build is finished. This provides immediate verification that the resources were named and created correctly.

## 2. Configured Input Variables
I created `variables.tf` to define the network parameters used throughout the project.

```hcl
# variables.tf
variable "KKE_VPC_CIDR" {
  default = "10.0.0.0/16"
}

variable "KKE_SUBNET_CIDR" {
  default = "10.0.1.0/24"
}
```

## 3. Developed the Main Infrastructure Manifest
I created `main.tf` to define the VPC, the private subnet, the restrictive security group, and the EC2 instance.

```hcl
# main.tf

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
```

## 4. Configured Outputs
I created `outputs.tf` to extract and display the names of the created resources.

```hcl
# outputs.tf
output "KKE_vpc_name" {
  value = aws_vpc.devops-priv-vpc.tags["Name"]
}

output "KKE_subnet_name" {
  value = aws_subnet.devops-priv-subnet.tags["Name"]
}

output "KKE_ec2_private" {
  value = aws_instance.devops-priv-ec2.tags["Name"]
}
```

## 5. Deployment and Verification
I initialized the Terraform environment and applied the configuration.

```bash
terraform init
terraform apply -auto-approve
```

I verified the success of the task using the AWS CLI and Terraform's refresh check.

```bash
# Verify the EC2 instance has no public IP and is in the correct subnet
aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-priv-ec2"
```

### Result
I verified that the `devops-priv-ec2` instance is **Running** with only a private IP (`10.0.1.4`). The security group successfully restricts all inbound access to the `10.0.0.0/16` range.

## Screenshot
![day-98-screenshot](day-98-screenshot.png)