#Creates S3 Bucket
resource "aws_s3_bucket" "object_storage" {
  #   bucket = "my-tf-test-bucket"
  acl = "private"
  tags = {
    Name = "${var.project_name}"
  }
}