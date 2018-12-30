
output "planningpoker_repository_url" {
  value = "${aws_ecr_repository.planningpoker.repository_url}"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "planningpoker" {
  name = "planningpoker"
}