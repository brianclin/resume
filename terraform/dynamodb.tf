resource "aws_dynamodb_table" "resume" {
  name           = local.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Site"

  attribute {
    name = "Site"
    type = "S"
  }

  tags = {
    Terraform = "true"
  }
}