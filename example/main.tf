provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
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
module "eg_prod_bastion_abc_label" {
  source     = "git::https://github.com/Shravan6488/terraform-label.git?ref=master"
  namespace  = "eg"
  stage      = "prod"
  name       = "bastion"
  attributes = ["abc"]
  delimiter  = "-"
  tags       = "${map("BusinessUnit", "ABC")}"
}

resource "aws_security_group" "eg_prod_bastion_abc" {
  name = "${module.eg_prod_bastion_abc_label.id}"
  tags = "${module.eg_prod_bastion_abc_label.tags}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "eg_prod_bastion_abc" {
  instance_type          = "t2.micro"
  tags                   = "${module.eg_prod_bastion_abc_label.tags}"
  vpc_security_group_ids = ["${aws_security_group.eg_prod_bastion_abc.id}"]
}

module "eg_prod_bastion_xyz_label" {
  source     = "git::https://github.com/Shravan6488/terraform-label.git?ref=master"
  namespace  = "eg"
  stage      = "prod"
  name       = "bastion"
  attributes = ["xyz"]
  delimiter  = "-"
  tags       = "${map("BusinessUnit", "XYZ")}"
}

resource "aws_security_group" "eg_prod_bastion_xyz" {
  name = "module.eg_prod_bastion_xyz_label.id"
  tags = "${module.eg_prod_bastion_xyz_label.tags}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "eg_prod_bastion_xyz" {
  instance_type          = "t2.micro"
  tags                   = "${module.eg_prod_bastion_xyz_label.tags}"
  vpc_security_group_ids = ["${aws_security_group.eg_prod_bastion_xyz.id}"]
}
