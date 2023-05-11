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

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.blin_resume.id
  key    = "index.html"
  source = "index.html"
  etag   = filemd5("index.html")
}

resource "aws_s3_object" "companies" {
  for_each = fileset("./assets/companies", "**")
  bucket   = aws_s3_bucket.blin_resume.id
  key      = "/assets/companies/${each.value}"
  source   = "./assets/companies/${each.value}"
  etag     = filemd5("./assets/companies/${each.value}")
}

resource "aws_s3_object" "skills" {
  for_each = fileset("./assets/skills", "**")
  bucket   = aws_s3_bucket.blin_resume.id
  key      = "/assets/skills/${each.value}"
  source   = "./assets/skills/${each.value}"
  etag     = filemd5("./assets/skills/${each.value}")
}

resource "aws_s3_object" "schools" {
  for_each = fileset("./assets/schools", "**")
  bucket   = aws_s3_bucket.blin_resume.id
  key      = "/assets/schools/${each.value}"
  source   = "./assets/schools/${each.value}"
  etag     = filemd5("./assets/schools/${each.value}")
}

resource "aws_s3_object" "css" {
  bucket = aws_s3_bucket.blin_resume.id
  key    = "/assets/styles.css"
  source = "./assets/styles.css"
  etag   = filemd5("./assets/styles.css")
}
