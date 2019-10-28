resource "aws_security_group" "custom-sg" {
  name        = "custom-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"

  ingress {
    from_port   = "8000"
    to_port     = "8008"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

  tags = {
    Name = "${var.project_name}"
  }
}

resource "aws_instance" "ec2Instance" {
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.custom-sg.id}"]
  subnet_id              = "${aws_subnet.public_subnet.id}"
  provisioner "local-exec" {
    command = "sleep 180"
  }
  # user_data = "${data.template_file.webapp_env.rendered}"
  
  user_data = <<-EOF
          #!/bin/bash
          yum install docker python-pip git -y
          pip install docker-compose
          service docker restart
          chkconfig docker on
          git clone https://github.com/SatishNaidi/website.git
          docker-compose -f website/docker-compose.yml up -d
          EOF
  tags = {
    Name = "${var.project_name}"
  }
}

output "endpoint_webapp" {
  value = "http://${aws_instance.ec2Instance.public_dns}:8000"
}

output "endpoint_object_store" {
  value = "http://${aws_instance.ec2Instance.public_dns}:8001"
}
output "endpoint_email" {
  value = "http://${aws_instance.ec2Instance.public_dns}:8002"
}

output "endpoint_database" {
  value = "http://${aws_instance.ec2Instance.public_dns}:8002"
}

