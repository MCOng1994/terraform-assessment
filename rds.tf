resource "aws_db_subnet_group" "rds" {
  name       = "${var.project}-${var.env}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "rds_master" {
  identifier              = "${var.project}-${var.env}-db-master"
  allocated_storage       = 20
  engine                  = "mariadb"
  engine_version          = "10.11"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
}
