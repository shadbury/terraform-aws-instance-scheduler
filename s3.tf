resource "aws_s3_bucket" "cf_templates" {
  bucket = "aonsw-instance-scheduler-cf-template"
  acl    = "private"
}

resource "aws_s3_bucket_object" "cf_template" {
  bucket = aws_s3_bucket.cf_templates.bucket
  key    = "instance-scheduler.yaml"
  source = "${path.module}/instance-scheduler.json"
  acl    = "private"
}

