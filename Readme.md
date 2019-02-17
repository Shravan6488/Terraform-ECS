##Example usage of the Alarm for monitoring the ECR cluster metric .
To test this example, clone the repoistry, cd into this example directory and run:

terraform init
terraform apply
A new empty cluster will be created in London region, and two metric alarms will be created for memory and cpu usage.

provider "aws" {
  region = "eu-central-1"
}

module "alarms" {
  source       = "/"
  namespace    = "ebot7"
  stage        = "prod"
  name         = "app"
  cluster_name = "${aws_ecs_cluster.default.name}"
  service_name = ""
  enabled      = "true"
}

resource "aws_ecs_cluster" "default" {
  name = "prod-app"
}
