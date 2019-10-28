
resource "aws_security_group" "db-security-grp" {
  vpc_id      = "${aws_vpc.myvpc.id}"
  name        = "postgres"
  description = "Allows in Bound traffic to Postgres for VPC"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  tags = {
    Name = "postgres"
  }
}



resource "aws_db_instance" "postgres" {
  identifier             = "mydb"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.5"
  instance_class         = "db.t2.micro"
  name                   = "cms"
  username               = "webapp"
  password               = "${var.password}"
  db_subnet_group_name   = "${aws_db_subnet_group.db_subnet_groups.name}"
  vpc_security_group_ids = ["${aws_security_group.db-security-grp.id}"]
  apply_immediately      = true
  #   snapshot_identifier  = "kill-me-now"
  skip_final_snapshot = true
}

