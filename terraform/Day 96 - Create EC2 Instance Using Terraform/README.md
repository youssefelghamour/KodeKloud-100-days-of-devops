# Day 96: Create EC2 Instance Using Terraform


## Objective
The objective is to provision a virtual server (EC2 instance) in AWS using Terraform. I configured the infrastructure to include an automated SSH key pair generation, specific OS image selection, and integration with existing network security groups.

## 1. EC2 and Key Management

### EC2 Instance

An **EC2 instance** is a virtual server provisioned in AWS. Its configuration is defined through several parameters:

* **AMI (Amazon Machine Image):** specifies the operating system and base image used to launch the instance. In this task, I used an Amazon Linux AMI.
* **Instance Type:** defines the instance's compute resources, such as CPU and memory. The task required `t2.micro`.
* **Tags:** identify and organize AWS resources. The instance was assigned the `devops-ec2` Name tag.

### Key Pair Management

SSH access requires a key pair consisting of a **private key** and a **public key**.

For this task, Terraform generated the RSA key pair locally using the **`tls` provider**. The `aws_key_pair` resource then registered the public key with AWS under the name `devops-kp`.

This allows the key-pair creation and EC2 configuration to be managed declaratively through Terraform rather than creating the AWS key pair manually through the console.

### Data Sources

The task required the instance to use the existing **default security group**. Rather than hardcoding its ID, I used a Terraform **data source** to look up the existing security group by name and retrieve its ID.

The resulting value can then be referenced by the EC2 resource:

```hcl
vpc_security_group_ids = [data.aws_security_group.default.id]
```

This demonstrates the distinction between **resources**, which Terraform creates or manages, and **data sources**, which Terraform uses to retrieve information about existing infrastructure.


## 2. Developed the Terraform Manifest
I created the `main.tf` file to handle the key generation, the data lookup, and the server provisioning.

```hcl
# main.tf

# Look up the existing default security group
data "aws_security_group" "default" {
  name = "default"
}

# Generate a new RSA private key
resource "tls_private_key" "devops_kp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS to create the Key Pair
resource "aws_key_pair" "devops_kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.devops_kp.public_key_openssh
}

# Provision the EC2 instance
resource "aws_instance" "devops_ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"

  key_name               = aws_key_pair.devops_kp.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "devops-ec2"
  }
}
```

## 3. Initialized and Applied Configuration
I executed the Terraform lifecycle commands to build the resources in the `us-east-1` region.

```bash
# Initialize the directory and download providers (AWS and TLS)
terraform init

# Review the creation plan for 3 resources
terraform plan

# Apply the changes to AWS
terraform apply -auto-approve
```

## 4. Verification
I verified the success of the deployment by checking Terraform's state and the actual instance status in AWS using the CLI.

```bash
# Verify resources are in the state file
terraform state list

# Check the running instance in AWS via CLI
aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-ec2"
```

### Result
I verified that the instance `devops-ec2` reached the **Running** state. It is successfully associated with the `devops-kp` key and the default security group. The server is now fully provisioned and accessible in the cloud.

## Screenshot
![day-96-screenshot](day-96-screenshot.png)