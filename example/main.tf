provider "aws" {
  access_key = "AKIAINQNYJ6OIQMODPTA"
  secret_key = "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"
  region = "eu-central-1"
}

module "alarms" {
  source       = "../"
  namespace    = "cp"
  stage        = "prod"
  name         = "app"
  cluster_name = "${aws_ecs_cluster.default.name}"
  service_name = ""
  enabled      = "true"
}

resource "aws_ecs_cluster" "default" {
  name = "cp-prod-app"
}
resource "aws_ecs_task_definition" "service" {
  family                = "service"
  container_definitions = "${file("task-definitions/service.json")}"

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-central-1a, eu-central-1b]"
  }
}
