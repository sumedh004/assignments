provider "aws" {
 region = var.region
}


resource "aws_vpc" "vpc" {
 cidr_block = var.vpc_cidr
 enable_dns_hostnames = "true"
 tags = {
 Name = "Custom VPC"
 }
}


resource "aws_internet_gateway" "gateway" {
 vpc_id = "${aws_vpc.vpc.id}"
 tags = {
 Name = "Custom IGW"
 }
}


resource "aws_route" "route" {
 route_table_id = "${aws_vpc.vpc.main_route_table_id}"
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = "${aws_internet_gateway.gateway.id}"
}


resource "aws_subnet" "private_subnet1" {
 vpc_id = "${aws_vpc.vpc.id}"
 cidr_block = "10.0.1.0/24"
 availability_zone = var.availability_zones[0]
tags = {
 Name = "Private Subnet 1"
 }
}


resource "aws_subnet" "private_subnet2" {
 vpc_id = "${aws_vpc.vpc.id}"
 cidr_block = "10.0.3.0/24"
 availability_zone = var.availability_zones[1]
 tags = {
 Name = "Private Subnet 2"
 }
}


resource "aws_subnet" "public_subnet1" {
 vpc_id = "${aws_vpc.vpc.id}"
 cidr_block = "10.0.2.0/24"
 availability_zone = var.availability_zones[0]
 tags = {
 Name = "Public Subnet 1"
 }
}


resource "aws_subnet" "public_subnet2" {
 vpc_id = "${aws_vpc.vpc.id}"
 cidr_block = "10.0.4.0/24"
 availability_zone = var.availability_zones[1]
 tags = {
 Name = "Public Subnet 2"
 }
}


resource "aws_db_subnet_group" "rds" {
 name = "rds grp"
 subnet_ids = ["${aws_subnet.private_subnet1.id}", "${aws_subnet.private_subnet2.id}"]
 tags = {
 Name = "RDS subnet grp"
 }
}


resource "aws_db_instance" "rds" {
 allocated_storage = 20
 engine = "mysql"
 engine_version = "8.0.27"
 instance_class = "db.t2.micro"
 db_name = "${var.database_name}"
 username = "${var.database_user}"
password = "${var.database_password}"
db_subnet_group_name = "${aws_db_subnet_group.rds.id}"
 publicly_accessible = "false"
 skip_final_snapshot = true
 tags = {
 Name = "sumedh-db"
 }
}


resource "aws_instance" "ec2" {
 ami = var.ec2ami
 instance_type = var.ec2type
 subnet_id = aws_subnet.public_subnet1.id
tags = {
 Name = "Frontend"
 }
depends_on = [aws_db_instance.rds]
}


resource "aws_elb" "custom-elb" {
 name = "custom-elb"
 subnets = [aws_subnet.public_subnet2.id]
 listener {
 instance_port = 80
 instance_protocol = "http"
 lb_port = 80
 lb_protocol = "http"
 }
 health_check {
 healthy_threshold = 2
 unhealthy_threshold = 2
 timeout = 2
 target = "HTTP:80/index.html"
 interval = 10
 }
 instances = [aws_instance.ec2.id]
 cross_zone_load_balancing = true
 idle_timeout = 10
 connection_draining = true
 connection_draining_timeout = 300
 tags = {
 Name = "custom-elb"
 }
}


resource "aws_efs_file_system" "efs" {
 creation_token = "efs"
 performance_mode = "generalPurpose"
 throughput_mode = "bursting"
tags = {
 Name = "EFS"
 }
}


resource "aws_efs_mount_target" "efs-mt" {
 file_system_id = aws_efs_file_system.efs.id
 subnet_id = aws_subnet.public_subnet1.id
}