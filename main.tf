# 1- Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "project_environment"
    Terraform   = "true"
  }
}

#2- Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  map_public_ip_on_launch = true
  availability_zone       = each.key
  tags = {
    Name      = "${each.key}_public_subnet"
    Terraform = "true"
  }
}

#3- Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = each.key

  tags = {
    Name      = "${each.key}_private_subnet"
    Terraform = "true"
  }
}


# 4- Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "project_igw"
  }
}


# 5- Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "project_igw_eip"
  }
}

# 6- Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["us-east-1a"].id
  tags = {
    Name = "project_nat_gateway"
  }
}
# 7- Create route tables for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "project_private_rtb"
    Terraform = "true"
  }
}
# 8- Create route table associatioin for Private subnets.
resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

# 9- Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "project_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}


#10- Create route table associations for Public subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# 11- Craete Security group for EC2 Instances
resource "aws_security_group" "WebSG" {
  name   = "WebSG"
  vpc_id = aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = var.allowed_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# 12- Create ec2 instances
resource "aws_key_pair" "MyKey_SSH" {
  key_name   = "MyKey"
  public_key = file("~/.ssh/MyKey.pub")
}

resource "aws_instance" "web" {
  ami                    = "ami-0dfcb1ef8550277af"
  instance_type          = "t2.micro"
  key_name               = "MyKey"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.WebSG.id]
  subnet_id              = aws_subnet.private_subnets["us-east-1a"].id
  root_block_device {
    encrypted = true
  }
  user_data = <<-EOF
    #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "This is server *1* in AWS Region US-EAST-1 in AZ US-EAST-1B " > /var/www/html/index.html
        EOF
  tags = {
    Name = "web_instance"
  }
}
resource "aws_instance" "app" {
  ami                    = "ami-0dfcb1ef8550277af"
  instance_type          = "t2.micro"
  key_name               = "MyKey"
  availability_zone      = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.WebSG.id]
  subnet_id              = aws_subnet.private_subnets["us-east-1b"].id
  root_block_device {
    encrypted = true
  }
  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "This is server *1* in AWS Region US-EAST-1 in AZ US-EAST-1B " > /var/www/html/index.html
        EOF
  tags = {
    Name = "APP_instance"
  }
}
/* Create the Load balancer including SG , Target Group , Listeners */
# 13 Security group for ALB
resource "aws_security_group" "ALBSG" {
  name        = "ALBSG"
  description = "security group for alb"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.WebSG.id]
  }
}

# 14- Create ALB
resource "aws_lb" "project_alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  subnets            = [aws_subnet.public_subnets["us-east-1a"].id, aws_subnet.public_subnets["us-east-1b"].id]
}

# 15- Create ALB target group
resource "aws_lb_target_group" "project_tg" {
  name     = "project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]
}

# 16- Create target attachments
resource "aws_lb_target_group_attachment" "tg_attach1" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.web.id
  port             = 80

  depends_on = [aws_instance.web]
}

resource "aws_lb_target_group_attachment" "tg_attach2" {
  target_group_arn = aws_lb_target_group.project_tg.arn
  target_id        = aws_instance.app.id
  port             = 80

  depends_on = [aws_instance.app]
}

# 17- Create listener
resource "aws_lb_listener" "listener_lb" {
  load_balancer_arn = aws_lb.project_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_tg.arn
  }
}

# 18- install EC2 Launch template
# resource "aws_launch_template" "Scaled_instance" {
#   name_prefix   = "ScaledLaunchTemplate-"
#   image_id      = "ami-0dfcb1ef8550277af"
#   instance_type = "t2.medium"
#   key_name      = "MyKey"

#   vpc_security_group_ids = [aws_security_group.WebSG.id]

#   user_data = base64encode(<<-EOF
#     #!/bin/bash
#     yum update -y
#     yum install httpd -y
#     systemctl start httpd
#     systemctl enable httpd
#     echo "Launched from Auto Scaling Group" > /var/www/html/index.html
#   EOF
#   )
# }
# # 19- Create EC2 Auto Security Group
# resource "aws_autoscaling_group" "ec2_auto_scaling" {
#   min_size             = 0
#   max_size             = 1
#   desired_capacity     = 1

#   vpc_zone_identifier  = [
#     aws_subnet.private_subnets["us-east-1a"].id,
#     aws_subnet.private_subnets["us-east-1b"].id
#   ]

#   target_group_arns = [aws_lb_target_group.project_tg.arn]

#   launch_template {
#     id      = aws_launch_template.Scaled_instance.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "asg_instance"
#     propagate_at_launch = true
#   }
# }

# # 20- associate the scaling group with ALB target group
# resource "aws_autoscaling_attachment" "asg_target" {
#   autoscaling_group_name = aws_autoscaling_group.ec2_auto_scaling.id
#   lb_target_group_arn    = aws_lb_target_group.project_tg.arn
# }


# 21- Database subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "rds-db-subnet"
  subnet_ids = [aws_subnet.private_subnets["us-east-1a"].id, aws_subnet.private_subnets["us-east-1b"].id]
}


# 22- Create the database Security Group
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "security group for RDS database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    security_groups = [aws_security_group.WebSG.id]
  }
}

# 23-  Create database instance
resource "aws_db_instance" "rds_instance" {
  allocated_storage      = 20
  identifier             = "rds-terraform"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.34"
  instance_class         = "db.t3.micro"
  db_name                = "project_rds"
  username               = "dolfined"
  password               = "dolfined"
  publicly_accessible    = false
  multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Name = "ExampleRDSServerInstance"
  }
}
