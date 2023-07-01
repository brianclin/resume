resource "aws_s3_object" "css" {
  bucket        = module.resume.s3_bucket_id
  key           = "/assets/styles.css"
  source        = "./assets/styles.css"
  etag          = filemd5("./assets/styles.css")
  cache_control = "public, max-age=31536000"
  content_type  = "text/css"
}

resource "aws_s3_object" "lazysizes" {
  bucket        = module.resume.s3_bucket_id
  key           = "/assets/lazysizes.min.js"
  source        = "./assets/lazysizes.min.js"
  etag          = filemd5("./assets/lazysizes.min.js")
  cache_control = "public, max-age=31536000"
  content_type  = "application/x-javascript"
}

resource "aws_s3_object" "favicon" {
  bucket        = module.resume.s3_bucket_id
  key           = "/assets/favicon.ico"
  source        = "./assets/favicon.ico"
  etag          = filemd5("./assets/favicon.ico")
  content_type  = "image/x-icon"
  cache_control = "public, max-age=31536000"
}
