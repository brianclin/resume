data "aws_cloudfront_cache_policy" "cache_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "cache_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "allviewer_except_host" {
  name = "Managed-AllViewerExceptHostHeader"
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"

  enabled                      = true
  default_root_object          = "index.html"
  aliases                      = ["brianclin.dev"]
  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    s3_oac = {
      domain_name           = aws_s3_bucket.blin_resume.bucket_regional_domain_name
      origin_access_control = "s3_oac"
    }

    api_gateway = {
      domain_name = trimsuffix(trimprefix(module.api_gateway.default_apigatewayv2_stage_invoke_url, "https://"), "/")
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_oac"
    viewer_protocol_policy = "redirect-to-https"
    use_forwarded_values   = false
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_optimized.id

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern             = "/count"
      target_origin_id         = "api_gateway"
      viewer_protocol_policy   = "redirect-to-https"
      use_forwarded_values     = false
      cache_policy_id          = data.aws_cloudfront_cache_policy.cache_disabled.id
      origin_request_policy_id = data.aws_cloudfront_origin_request_policy.allviewer_except_host.id

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "DELETE", "POST", "PATCH"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
