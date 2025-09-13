# key pair (login)
resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ec2"
  public_key = file("terra-key-ec2.pub")
}

# vpc & group security
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "my_security_group" {
  name        = "allow_tls"
  description = "Allow Transport Layer Security inbound traffic & all outbound traffic"
  vpc_id      = aws_default_vpc.default.id #interpolation is way to extract value from other resource

  #inbound
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
  }
  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "my node app from anywhere"
  }
  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
}

# ec2 instance
resource "aws_instance" "my_instance" {
  ami             = var.ec2_ami_id #Amazon Linux 2 AMI (HVM), SSD Volume Type - us-east-1
  instance_type   = var.ec2_instance_type
  # instance_type   = "t2.micro"    # both way are correct. But using variable is better.
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_security_group.name]

  root_block_device {
    volume_size = var.ec2_root_block_device   # 10
    volume_type = "gp3"
  }
  tags = {
    "Name" = "MyInstance"
  }
}

