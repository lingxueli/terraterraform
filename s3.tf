resource "aws_s3_bucket" "bucket" {
  bucket = "lisa-www-prod-12345"

  tags = {
    Name        = "lisa-www-prod-12345"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "playbook" {
  bucket = aws_s3_bucket.bucket.id
  key    = "playbook/playbook.yaml"
  source = "playbook.yaml"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("playbook.yaml")
}