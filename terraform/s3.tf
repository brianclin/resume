resource "aws_s3_bucket" "blin_resume" {
  bucket = "blin-resume"

  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_acl" "blin_resume" {
  bucket = aws_s3_bucket.blin_resume.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "blin_resume" {
  bucket = aws_s3_bucket.blin_resume.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = aws_s3_bucket.blin_resume.id
  policy = data.aws_iam_policy_document.cloudfront.json
}

data "aws_iam_policy_document" "cloudfront" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.blin_resume.arn,
      "${aws_s3_bucket.blin_resume.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [module.cdn.cloudfront_distribution_arn]
    }
  }
}
