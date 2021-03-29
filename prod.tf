variable "whitelist" {   
   type = list(string)
}        
variable "image_id" { 
   type = string
}            
variable "instance_type" {
   type = string
}       
variable "web_desired_capacity" {
   type = number
}
variable "web_max_size" {
   type = number
}         
variable "web_min_size" {
   type = number
}         

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "prod_files"{
  bucket = "jamjamtfiles20191118"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1c"
  tags = {
    "Teraform" : "true"
  }
}

resource "aws_security_group" "prod_web"{
  name        = "prod_web"
  description = "Allow standard http and https port inbound and everything outbound"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist
 }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist  

   }

  tags = {

  "Terraform" : "true"
 }  
}

resource "aws_instance" "prod_web"{
  count = 2

  ami           = "ami-045805cfa04cb5a27"
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.prod_web.id
 ]
  
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_eip_association" "prod_web" {
  instance_id    = aws_instance.prod_web.0.id
  allocation_id  = aws_eip.prod_web.id
}

resource "aws_eip" "prod_web"{
 

  tags = {
    "Terraform" : "true"

  }  
}

resource "aws_elb" "prod_web" {
  name            = "prod-web"
  instances       = aws_instance.prod_web.*.id
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [aws_security_group.prod_web.id]
  
  listener {
   instance_port     = 80
   instance_protocol = "http"
   lb_port           = 80  
   lb_protocol       = "http"

  }
}

