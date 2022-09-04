resource "aws_s3_bucket" "bucket" {
  bucket = "lisa-www-prod-12345"

  tags = {
    Name        = "lisa-www-prod-12345"
    Environment = "Dev"
  }
}