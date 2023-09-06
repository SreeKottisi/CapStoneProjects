resource "aws_key_pair" "capstone1-key" {
  key_name   = "capstone1-key"
  public_key = file(var.PUB_KEY)
}

/*Internet Gateway: a network device that allows traffic to flow between your VPC and the internet. 
It is a fundamental component of any VPC network.*/
resource "aws_internet_gateway" "capstone1-internet-gateway" {
  vpc_id = aws_vpc.capstone1-vpc.id
  tags = {
    Name = "capstone1-internet-gateway"
  }
}

#Creating 4Subnets, 2Private, 2public
/*The public subnet will have a public IP address assigned to each instance that is launched in it, while 
the private subnet will not. This allows you to control which instances are accessible from the 
internet and which are not.*/

#2Public Subnets
resource "aws_subnet" "capstone1-public-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.capstone1-vpc.id
  cidr_block              = var.capstone1-public-subnet-cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-capstone1-public-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}
#2Private Subnets
resource "aws_subnet" "capstone1-private-subnet" {
  count             = 2
  vpc_id            = aws_vpc.capstone1-vpc.id
  cidr_block        = var.capstone1-private-subnet-cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = join("-", ["${var.environment}-capstone1-private-subnet", data.aws_availability_zones.available.names[count.index]])
  }
}


/*Route table for public subnets, this ensures that all instances launched in 
public subnet will have access to the internet*/
resource "aws_route_table" "capstone1-public-route-table" {
  vpc_id = aws_vpc.capstone1-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.capstone1-internet-gateway.id
  }
  tags = {
    Name = "${var.environment}-capstone1-public-route-table"
  }
}

#Elastic IP 
/*An EIP is a public IP address that can be assigned to an instance or load balancer. EIPs can be used to 
make your instances accessible from the internet.*/
resource "aws_eip" "capstone1-elastic-ip" {
  tags = {
    Name = "${var.environment}-capstone1-elastic-ip"
  }
}


#AWS NAT Gateway:  
/*is a network device that allows instances in a private subnet to access the internet. 
It does this by translating the private IP addresses of the instances to public IP addresses.*/
resource "aws_nat_gateway" "capstone1-nat-gateway" {
  allocation_id = aws_eip.capstone1-elastic-ip.id
  subnet_id     = aws_subnet.capstone1-public-subnet[0].id
  depends_on    = [aws_internet_gateway.capstone1-internet-gateway]
  tags = {
    Name = "capstone1-nat-gateway"
  }
}


# Application Load Balancer Resources
/*Creates an Application Load Balancer (ALB) that is accessible from the internet, uses the application load balancer 
type, and uses the ALB security group. The ALB will be created in all public subnets.*/
resource "aws_lb" "capstone1-alb" {
  name               = "${var.environment}-capstone1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.capstone1-alb-security-group.id]
  subnets            = [for i in aws_subnet.capstone1-public-subnet : i.id]
}

#creating a target group that listens on port 80 and uses the HTTP protocol. 
resource "aws_lb_target_group" "capstone1-target-group" {
  name     = "${var.environment}-capstone1-tgrp"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.capstone1-vpc.id
  health_check {
    path    = "/login?from=%2F"
    matcher = 200
  }
}

#Application Load Balancer: Is a powerful tool that can help you improve the performance, security, and 
#availability of your applications
/*Creating a listener that listens on port 8080 and uses the HTTP protocol. The listener will be associated 
with the application load balancer*/
resource "aws_lb_listener" "capstone1-alb-listener" {
  load_balancer_arn = aws_lb.capstone1-alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.capstone1-target-group.arn
  }
  tags = {
    Name = "${var.environment}-capstone1-alb-listenter"
  }
}

#AutoScalingGroup 
/*if the number of requests to the target groups increases, the Auto Scaling group will automatically scale the number 
of instances in the group up to handle the increased load. If the number of requests to the target groups decreases, 
the Auto Scaling group will automatically scale the number of instances in the group down to save costs.*/
resource "aws_autoscaling_group" "capstone1-auto-scaling-group" {
  name             = "capstone1-auto-scaling-group"
  desired_capacity = 1
  max_size         = 2
  min_size         = 1
  vpc_zone_identifier = flatten([
    aws_subnet.capstone1-private-subnet.*.id,
  ])
  target_group_arns = [
    aws_lb_target_group.capstone1-target-group.arn,
  ]
  launch_template {
    id      = aws_launch_template.capstone1-launch-template.id
    version = aws_launch_template.capstone1-launch-template.latest_version
  }
}


#AWS Route-Table:  A route table is a collection of routes that determines how traffic is routed within a VPC. 
/*In this case, the route table will route all traffic to the NAT gateway, which will then forward the traffic 
to the internet.*/
resource "aws_route_table" "capstone1-private-route-table" {
  vpc_id = aws_vpc.capstone1-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.capstone1-nat-gateway.id
  }
  tags = {
    Name = "${var.environment}-capstone1-private-route-table"
  }
}

#Create two route table associations, one for the public subnet and one for the private subnet.
#public subnet will be associated with the public route table
resource "aws_route_table_association" "capstone1-public-rt-assoc" {
  count          = 2
  subnet_id      = aws_subnet.capstone1-public-subnet[count.index].id
  route_table_id = aws_route_table.capstone1-public-route-table.id
}
#Private subnet will be associated with the private route table
resource "aws_route_table_association" "capstone1-private-rt-assoc" {
  count          = 2
  subnet_id      = aws_subnet.capstone1-private-subnet[count.index].id
  route_table_id = aws_route_table.capstone1-private-route-table.id
}

# Launch Template and ASG Resources
resource "aws_launch_template" "capstone1-launch-template" {
  name          = "${var.environment}-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.capstone1-key.key_name
  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.capstone1-asg-security-group.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-capstone1-asg-ec2"
    }
  }
  user_data = base64encode("${var.ec2_user_data}")
}

resource "aws_instance" "capstone1-ops-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.capstone1-key.key_name
  subnet_id     = aws_subnet.capstone1-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.capstone1-asg-security-group.id]
  tags = {
    Name    = "capstone1-ops-server"
  }
  connection {
    user        = var.USER
    private_key = file("capstone-project1-key")
    host        = self.public_ip
  }
}
