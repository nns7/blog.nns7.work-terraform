# --------------------------------
# CloudFront
resource "aws_cloudfront_distribution" "hugo" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.cf_price_class
  http_version        = "http2"

  ## CloudFrontの代替ドメイン（CNAME）設定
  aliases = ["blog.nns7.work"]

  ## オリジンの設定
  origin {
    origin_id                = aws_s3_bucket.hugo.id
    domain_name              = aws_s3_bucket.hugo.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.hugo.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.hugo.id
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https" ## HTTP通信をHTTPS通信にリダイレクト
    min_ttl                = var.cf_min_ttl
    default_ttl            = var.cf_default_ttl
    max_ttl                = var.cf_max_ttl

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.add-index-function.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false ## ACMで作成した証明書を使用するため無効
    acm_certificate_arn            = "arn:aws:acm:us-east-1:${var.aws_account_id}:certificate/${var.certificate_id}"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.minimum_viewer_tls_version
  }
}

## OACを作成
resource "aws_cloudfront_origin_access_control" "hugo" {
  name                              = "hugo-cf-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# --------------------------------
# CloudFront Functions
resource "aws_cloudfront_function" "add-index-function" {
  name    = "add-index-function"
  runtime = "cloudfront-js-1.0"
  comment = "Add index.html to the path"
  publish = true
  code    = file("${path.module}/addIndexFunction.js")
}