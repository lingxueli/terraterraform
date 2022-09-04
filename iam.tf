resource "aws_iam_role" "ec2" {
  name = "ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2_profile"
  role = aws_iam_role.ec2.name
}

# s3 policy
data "aws_iam_policy_document" "bucket" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
      "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
    ]
  }
}

resource "aws_iam_policy" "bucket" {
  name   = "bucket_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.bucket.json
}
