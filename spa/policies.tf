data "aws_cloudfront_cache_policy" "caching_disabled" {
  id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
}

resource "aws_cloudfront_cache_policy" "admin" {
  name    = "AdminDev-CachingOptimized"
  comment = "Cache admin assets in a day (development/UAT environment)"

  min_ttl     = 600
  max_ttl     = 86400
  default_ttl = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

resource "aws_cloudfront_origin_request_policy" "admin" {
  name    = "AdminDev-OriginRequest"
  comment = "Origin request policy for admin (development/UAT environment). This is used to get device type of viewers"

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["CloudFront-Is-Mobile-Viewer"]
    }
  }
  cookies_config {
    cookie_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_response_headers_policy" "admin" {
  name    = "AdminDev-ResponseHeaders"
  comment = "Security headers policy for admin (development/UAT environment)"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      preload                    = true
      override                   = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    xss_protection {
      protection = true
      report_uri = sentry_key.admin.dsn_csp
      override   = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    content_security_policy {
      content_security_policy = "default-src 'none'; script-src 'self' 'unsafe-eval' https://browser.sentry-cdn.com https://js.sentry-cdn.com; script-src-elem 'self' https://fonts.googleapis.com https://www.clarity.ms https://sentry.io https://*.ingest.sentry.io 'sha256-ZKop3V8IXvVNYkkFYaHMe4RC9Bp9tGsA+IQgBcrMuGk=' 'sha256-X6fYG/6EpD3PXk4LnIsgxVqgiz86BfAN45FNDo6+2SM='; script-src-attr 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; style-src-elem 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https: blob:; font-src 'self' data: https://fonts.googleapis.com https://fonts.gstatic.com; connect-src https://*.saladin.vn https://sentry.io https://*.sentry.io https://s3.ap-southeast-1.amazonaws.com wss://ws-ap1.pusher.com https://sockjs-ap1.pusher.com https://*.clarity.ms https://cdn.jsdelivr.net https://unpkg.com; media-src https://staging.cdn.saladin.vn https://cdn.saladin.vn https://s3.ap-southeast-1.amazonaws.com; object-src 'none'; child-src 'self' blob:; frame-src blob: https://*.saladin.vn https://s3.ap-southeast-1.amazonaws.com; worker-src 'self' blob:; frame-ancestors 'none'; form-action 'none'; upgrade-insecure-requests; block-all-mixed-content; base-uri 'none'; manifest-src 'self'; report-uri https://o4505356987727872.ingest.sentry.io/api/5715127/security/?sentry_key=9a2e847852794d7da9704a5366c82334; report-to ${sentry_key.admin.dsn_csp}"
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Server"
      value    = var.domain_name
      override = true
    }
    items {
      header   = "X-Powered-By"
      value    = var.domain_name
      override = true
    }
    items {
      header   = "X-Robots-Tag"
      value    = "noindex, nofollow"
      override = true
    }
  }

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 10
  }
}
