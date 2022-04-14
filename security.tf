resource "aws_security_group" "ecs_security_group" {
  name        = "metabase-ecs-sg"
  description = "Allow traffic in the ECS service"
  vpc_id      = aws_vpc.metabase_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "metabase-db-sg"
  description = "Allow traffic from the ECS service to the database"
  vpc_id      = aws_vpc.metabase_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_security_group" {
  name        = "metabase-lb-sg"
  description = "Allow traffic in the Load Balancer"
  vpc_id      = aws_vpc.metabase_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.metabase_vpc.cidr_block, "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
