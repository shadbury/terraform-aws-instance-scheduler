resource "random_id" "bucket_suffix" {
  byte_length = 4
  prefix      = "instance-scheduler-"
}

resource "aws_s3_bucket" "cf_templates" {
  bucket = "${random_id.bucket_suffix.hex}-cf-templates"
  acl    = "private"
}

resource "aws_s3_bucket_object" "cf_template" {
  bucket = aws_s3_bucket.cf_templates.bucket
  key    = "instance-scheduler.yaml"
  source = "${path.module}/instance-scheduler.json"
  acl    = "private"
}

