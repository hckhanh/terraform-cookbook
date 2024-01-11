resource "aws_s3_bucket" "uat_admin" {
  bucket        = var.uat_domain_name
  force_destroy = true

  tags = {
    Name        = "Saladin-Admin"
    Environment = "UAT"
  }
}

resource "aws_cloudfront_origin_access_control" "uat_admin" {
  name                              = aws_s3_bucket.uat_admin.bucket_regional_domain_name
  description                       = "Allow access to ${aws_s3_bucket.uat_admin.bucket_regional_domain_name} bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "uat_admin" {
  enabled = true

  is_ipv6_enabled = true
  aliases         = [var.uat_domain_name]
  http_version    = "http2and3"
  price_class     = "PriceClass_All"
  comment         = var.uat_domain_name

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.admin.arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
  }

  origin {
    domain_name              = aws_s3_bucket.uat_admin.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.uat_admin.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.uat_admin.id
    origin_shield {
      enabled              = true
      origin_shield_region = var.aws_region
    }
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.uat_admin.bucket_domain_name
    compress               = false
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.admin.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.admin.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.admin_spa_direct.arn
    }
    function_association {
      event_type   = "viewer-response"
      function_arn = aws_cloudfront_function.admin_sentry_profiling.arn
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.aws_cache_paths
    content {
      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = aws_s3_bucket.uat_admin.bucket_domain_name
      compress               = true
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]

      cache_policy_id            = aws_cloudfront_cache_policy.admin.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.admin.id
      response_headers_policy_id = aws_cloudfront_response_headers_policy.admin.id
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Saladin-Admin"
    Environment = "UAT"
  }
}

data "aws_iam_policy_document" "uat_admin" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.uat_admin.arn}/*"]
    actions   = ["s3:GetObject"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.uat_admin.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "uat_admin" {
  bucket = aws_s3_bucket.uat_admin.id
  policy = data.aws_iam_policy_document.uat_admin.json
}

resource "aws_route53_record" "uat_admin" {
  count   = length(local.types)
  name    = var.uat_domain_name
  type    = local.types[count.index]
  zone_id = data.aws_route53_zone.admin.id

  alias {
    name                   = aws_cloudfront_distribution.uat_admin.domain_name
    zone_id                = aws_cloudfront_distribution.uat_admin.hosted_zone_id
    evaluate_target_health = false
  }
}
