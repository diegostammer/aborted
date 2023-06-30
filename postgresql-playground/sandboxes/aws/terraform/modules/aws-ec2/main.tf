terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}

/*

An AWS key pair is a set of cryptographic keys used for secure access to Amazon EC2 instances.
It consists of a public key and a private key that are generated together and associated with each other.

*/
resource "aws_key_pair" "this" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_file)
}

/*

An AWS instance refers to a virtual server running on the Amazon Elastic Compute Cloud (EC2) service.
It is a fundamental component of AWS and provides scalable computing resources for various types of workloads. 

*/
resource "aws_instance" "this" {
  instance_type = var.instance_type
  ami           = var.ami_id
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.this.key_name

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.ssh_key_file)
    timeout     = "2m"
    host        = self.public_ip
  }

  tags = {
    Name = var.instance_name
  }
}

/*

An AWS security group is a virtual firewall that controls inbound and outbound traffic for AWS resources,
such as Amazon EC2 instances, within a Virtual Private Cloud (VPC).
It acts as a barrier to protect resources from unauthorized access while allowing legitimate traffic to pass through.

*/
resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  name   = "${var.instance_name}-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

/*

An AWS Network Interface Security Group Attachment is used to attach a security group to a network interface.
It associates a security group with a specific network interface within a Virtual Private Cloud (VPC).

*/
resource "aws_network_interface_sg_attachment" "this" {
  security_group_id    = aws_security_group.this.id
  network_interface_id = aws_instance.this.primary_network_interface_id
}
