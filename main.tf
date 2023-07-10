module "resume" {
  source = "git::https://github.com/brianclin/terraform-aws-s3-website.git?ref=v1.1.1"

  domain_name            = "brianclin.dev"
  bucket_name            = "blin-resume"
  create_hosted_zone     = true
  enable_count_api       = true
  api_gateway_invoke_url = module.api_gateway.default_apigatewayv2_stage_invoke_url
  index_html_source      = "index-critical.html"
}
