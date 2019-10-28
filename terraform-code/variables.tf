
variable "project_name" {
  description = "Identifiable name Project"
  default     = "Cambridge"
}


variable "password" {
  description = "Identifiable name Project"
  default     = "somepassword"
}

variable "environment" {
  type        = "string"
  default     = "dev"
  description = "Please provide the environment"
}

variable "env" {
  description = "Identifiable name Project"
  default     = "Cambridge"
}

variable "ami" {
  description = "AMI to Launch EC2 Instance for Running Docker"
  default     = "ami-0077174c1f13f8f04"
}

variable "region" {
  description = "Choose a region to launch Infra"
  default     = "us-west-2"
}

#Dynamic AZs Information
data "aws_availability_zones" "azs" {
  state = "available"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  default     = "10.0.0.0/16"
}

variable "public_cidr" {
  description = "CIDR Block for Public Subnet"
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR Block for Private Subnet"
  default     = "10.0.2.0/24"
}

variable "key_name" {
  description = "KeyName to Launch EC2 Instance"
}

variable "instance_type" {
  description = "Instance Type for Running the Docker"
  default     = "t2.micro"
}
