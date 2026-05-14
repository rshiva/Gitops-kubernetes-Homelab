resource "aws_dynamodb_table" "users"{
  name  = "${var.project_name}-${var.env}-users"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key = "id"
  point_in_time_recovery{
    enabled=true
  }
  server_side_encryption{
     enabled=true
  }

  range_key ="created_at"

  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "created_at"
    type = "S"
  }
  tags = {
    Name = "${var.project_name}-${var.env}-users-table"
  }
}
