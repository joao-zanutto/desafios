resource "aws_db_instance" "metabase_db" {
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 20
  engine                              = "postgres"
  engine_version                      = "13.4"
  db_name                             = "metabasedb"
  username                            = var.db_username
  password                            = var.db_password
  customer_owned_ip_enabled           = false
  deletion_protection                 = false
  iam_database_authentication_enabled = false
  iops                                = 0
  max_allocated_storage               = 0
  enabled_cloudwatch_logs_exports     = []
  storage_encrypted                   = true
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.db_security_group.id]
  skip_final_snapshot                 = true
  apply_immediately                   = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "metabase-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}
