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

resource "aws_s3_object" "html" {
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "index.html"
  source        = "index-critical.html"
  etag          = filemd5("index-critical.html")
  content_type  = "text/html"
  cache_control = "public, max-age=31536000"
}

resource "aws_s3_object" "companies" {
  for_each      = fileset("./assets/companies", "**")
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/companies/${each.value}"
  source        = "./assets/companies/${each.value}"
  etag          = filemd5("./assets/companies/${each.value}")
  content_type  = "image/png"
  cache_control = "public, max-age=31536000"
}

resource "aws_s3_object" "svg" {
  for_each      = fileset("./assets/svg", "**")
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/svg/${each.value}"
  source        = "./assets/svg/${each.value}"
  etag          = filemd5("./assets/svg/${each.value}")
  cache_control = "public, max-age=31536000"
  content_type  = "image/svg+xml"
}

resource "aws_s3_object" "schools" {
  for_each      = fileset("./assets/schools", "**")
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/schools/${each.value}"
  source        = "./assets/schools/${each.value}"
  etag          = filemd5("./assets/schools/${each.value}")
  cache_control = "public, max-age=31536000"
  content_type  = "image/png"
}

resource "aws_s3_object" "css" {
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/styles.css"
  source        = "./assets/styles.css"
  etag          = filemd5("./assets/styles.css")
  cache_control = "public, max-age=31536000"
  content_type  = "text/css"
}

resource "aws_s3_object" "lazysizes" {
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/lazysizes.min.js"
  source        = "./assets/lazysizes.min.js"
  etag          = filemd5("./assets/lazysizes.min.js")
  cache_control = "public, max-age=31536000"
  content_type  = "application/x-javascript"
}

resource "aws_s3_object" "favicon" {
  bucket        = aws_s3_bucket.blin_resume.id
  key           = "/assets/favicon.ico"
  source        = "./assets/favicon.ico"
  etag          = filemd5("./assets/favicon.ico")
  content_type  = "image/x-icon"
  cache_control = "public, max-age=31536000"
}
