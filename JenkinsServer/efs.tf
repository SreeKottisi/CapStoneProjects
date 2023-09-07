# Create an Amazon EFS file system
resource "aws_efs_file_system" "capstone1-efs" {
  creation_token   = "capstone1-efs" # Modify as needed
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags = {
    Name = "capstone1-efs"
  }
}

# Create a mount target for the EFS in your subnet
resource "aws_efs_mount_target" "capstone1-efs-mount-target" {
  file_system_id  = aws_efs_file_system.capstone1-efs.id
  subnet_id       = aws_subnet.capstone1-private-subnet[0].id
  security_groups = [aws_security_group.capstone1-asg-security-group.id]
}

# Create a security group rule to allow NFS traffic
resource "aws_security_group_rule" "capstone1-efs-rule" {
  type        = "ingress"
  from_port   = 2049  # NFS port
  to_port     = 2049
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Use the security group of your Jenkins instances
  security_group_id = aws_security_group.capstone1-efs-sg.id
}

resource "aws_security_group" "capstone1-efs-sg" {
  name_prefix = "capstone1-efs-sg-"

  vpc_id = aws_vpc.capstone1-vpc.id # Reference the VPC ID where your EFS and Jenkins instances are located

  # Ingress rule for NFS traffic (port 2049) from the Jenkins instances
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.capstone1-asg-security-group.id]  # Reference the Jenkins security group
  }

  # Egress rule for outgoing traffic (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}