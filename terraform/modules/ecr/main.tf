locals {
  name_prefix = "${var.project_name}-${var.env}"
}
resource "aws_ecr_repository" "devopsrt-home-lab"{
  name = local.name_prefix
  image_tag_mutability = "IMMUTABLE" #dont overwrite tags

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = { Name = "${local.name_prefix}-ecr_repository"}

}

resource "aws_ecr_lifecycle_policy" "devopsrt-home-lab-policy" {
  repository = aws_ecr_repository.devopsrt-home-lab.name
  tags = { Name = "${local.name_prefix}-ecr_repository-policy"}

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 10 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
