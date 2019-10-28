#https://nickcharlton.net/posts/terraform-aws-vpc.html


# VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}"
  }
}

#Security Group for VPC
resource "aws_security_group" "ssh-allowed" {
  vpc_id      = "${aws_vpc.myvpc.id}"
  name        = "allow_ssh"
  description = "Allow SSH Inbound traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    // This means, all ip address are allowed to ssh ! 
    // Do not do it in the production. 
    // Put your office or home address in it!
    cidr_blocks = ["0.0.0.0/0"]
  }
  //If you do not add this rule, you can not reach the NGIX  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-allowed"
  }
}


# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "${var.project_name}"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.myvpc.id}"
  cidr_block              = "${var.public_cidr}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.azs.names[0]}"
  tags = {
    Name = "Pub_${var.project_name}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  cidr_block        = "${var.private_cidr}"
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  tags = {
    Name = "Pri_${var.project_name}"
  }
}

resource "aws_db_subnet_group" "db_subnet_groups" {
  name        = "main"
  subnet_ids  = ["${aws_subnet.public_subnet.id}", "${aws_subnet.private_subnet.id}"]
  description = "DB Subnet Group"
  tags = {
    Name = "DB_${var.project_name}"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "RT_${var.project_name}"
  }
}

#Public Route
resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.public_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

# Associating Public Subnet to Public Route Table
resource "aws_route_table_association" "subnetassociation" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
  depends_on    = ["aws_internet_gateway.igw"]
  tags = {
    Name = "Pri_${var.project_name}"
  }
}

resource "aws_route_table" "privatesubnet_rt_table" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  }

  tags = {
    Name = "Pri_${var.project_name}"
  }
}

resource "aws_route_table_association" "privatesubnet_rt_table_assocation" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.privatesubnet_rt_table.id}"
}