resource "aws_ecs_cluster" "metabase_cluster" {
  name = "metabase-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "metabase_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.metabase_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "metabase_task_definition" {
  family                   = "metabase-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  cpu                      = 512
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name      = "${var.container_name}"
      image     = "${var.image}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "metabase-ecs-logs",
          awslogs-region        = "us-west-2",
          awslogs-create-group  = "true",
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = "${tonumber(var.container_port)}"
          hostPort      = "${tonumber(var.container_port)}"
        }
      ]
      environment = [
        {
          name  = "JAVA_OPTS"
          value = "-Xmx2048m"
        },
        {
          name  = "MB_DB_DBNAME"
          value = "${aws_db_instance.metabase_db.db_name}"
        },
        {
          name  = "MB_DB_HOST"
          value = "${aws_db_instance.metabase_db.address}"
        },
        {
          name  = "MB_DB_PASS"
          value = "${var.db_password}"
        },
        {
          name  = "MB_DB_PORT"
          value = "${tostring(aws_db_instance.metabase_db.port)}"
        },
        {
          name  = "MB_DB_TYPE"
          value = "${aws_db_instance.metabase_db.engine}"
        },
        {
          name  = "MB_DB_USER"
          value = "${var.db_username}"
        }
      ]
    },
  ])
}

resource "aws_ecs_service" "metabase_service" {
  name            = "metabase-service"
  cluster         = aws_ecs_cluster.metabase_cluster.id
  task_definition = aws_ecs_task_definition.metabase_task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.metabase_target_group.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
