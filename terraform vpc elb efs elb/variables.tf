variable "ec2ami" {
 type = string
 default = "ami-04505e74c0741db8d"
}
variable "ec2type" {
 type = string
 default = "t2.micro"
}
variable "vpc_cidr" {
 type = string
 default = "10.0.0.0/16"
}
variable "region" {
 type = string
 default = "us-east-1"
}
variable "instance_type" {
 type = string
 default = "t2.micro"
}
variable "allowed_cidr_blocks" {
 type = list
 default = ["0.0.0.0/0"]
}
variable "availability_zones" {
 type = list
 default = ["us-east-1a", "us-east-1b"]
}
variable "database_name" {
 type = string
 default = "sumedhdb"
}
variable "database_user" {
 type = string
 default = "sumedh9999"
}
variable "database_password" {
 type = string
 default = "sumedh9999"
}
variable "ami" {
 type = string
 default = "ami-0dc2d3e4c0f9ebd18"
 }