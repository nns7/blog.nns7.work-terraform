
# --------------------------------
# CloudFront
resource "aws_cloudfront_distribution" "hugo" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object
  price_class         = var.cf_price_class
  http_version        = "http2"

  ## オリジンの設定
  origin {
    origin_id                = aws_s3_bucket.hugo.id
    domain_name              = aws_s3_bucket.hugo.bucket_regional_domain_name
    origin_path              = var.origin_path
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
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false ## ACMで作成した証明書を使用するため無効
    acm_certificate_arn            = "arn:aws:acm:${var.aws_region}:${var.aws_account_id}:certificate/${var.certificate_id}"
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