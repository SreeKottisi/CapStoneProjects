resource "aws_key_pair" "capstone1-key" {
  key_name   = "capstone1-key"
  public_key = file(var.PUB_KEY)
}

# Create an EC2 instance for Jenkins master within an Auto Scaling Group
resource "aws_launch_template" "capstone1-jenkins-master-template" {
  name_prefix   = "capstone1-jenkins-master-lt-"
  description   = "Launch Template for Jenkins"
  image_id      = var.AMIS[var.REGION]                # Jenkins-specific AMI ID
  instance_type = "t2.micro"                          # Choose an appropriate instance type
  key_name      = aws_key_pair.capstone1-key.key_name # Replace with your SSH key pair name
  user_data     = filebase64("jenkins-install.sh")
  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.capstone1-priv-1.id
    security_groups             = [aws_security_group.capstone1-jenkins-master-ec2.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "capstone1-jenkins-master-instance" # Name for the EC2 instances
    }
  }
}
# Create an EC2 instance for Jenkins master within an Auto Scaling Group
resource "aws_autoscaling_group" "capstone1-jenkins-master-asg" {
  # no of instances
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  # Connect to the target group
  target_group_arns = [aws_lb_target_group.capstone1-jenkins-elb-tg.arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    aws_subnet.capstone1-priv-1.id
  ]

  launch_template {
    id      = aws_launch_template.capstone1-jenkins-master-template.id
    version = "$Latest"
  }
}