resource "aws_cloudfront_function" "admin_spa_direct" {
  name    = "admin-spa-redirect"
  comment = "Redirects all requests to the admin SPA (index.html)"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/functions/admin-spa-redirect.js")
  publish = true
}

resource "aws_cloudfront_function" "admin_sentry_profiling" {
  name    = "admin-sentry-profiling"
  comment = "Add profiling to document response header"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/functions/admin-sentry-profiling.js")
  publish = true
}
