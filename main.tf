module "resume" {
  source = "git::https://github.com/brianclin/terraform-aws-s3-website.git?ref=v1.2.0"

  domain_name        = "brianclin.dev"
  bucket_name        = "blin-resume"
  create_hosted_zone = false
  enable_count_api   = false
  index_html_source  = "index-critical.html"
}
