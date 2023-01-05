# --------------------------------
# 静的サイト公開用バケット
resource "aws_s3_bucket" "hugo" {
  bucket = "blog.nns7.work"
}

## バケットポリシー
resource "aws_s3_bucket_policy" "hugo" {
  bucket = aws_s3_bucket.hugo.bucket
  policy = data.aws_iam_policy_document.s3_hugo_policy.json
}

## パブリックアクセスの設定
resource "aws_s3_bucket_public_access_block" "hugo" {
  bucket                  = aws_s3_bucket.hugo.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## バージョニング設定
resource "aws_s3_bucket_versioning" "hugo" {
  bucket = aws_s3_bucket.hugo.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

## 暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "hugo" {
  bucket = aws_s3_bucket.hugo.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

## オブジェクトACLを無効化
resource "aws_s3_bucket_ownership_controls" "hugo" {
  bucket = aws_s3_bucket.hugo.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

## ライフサイクルルール設定
resource "aws_s3_bucket_lifecycle_configuration" "hugo" {
  bucket = aws_s3_bucket.hugo.bucket
  rule {
    id     = "assets"
    status = "Enabled"
    ## 未完了なマルチパートアップロードの削除
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    ## 古いオブジェクトの保存期間
    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days           = 1
    }
  }
}

# --------------------------------
# CloudFrontのアクセスログ格納用バケット
resource "aws_s3_bucket" "cloudfront_logging" {
  bucket = "cloudfront-logging.nns7.work"
}

## パブリックアクセスの設定
resource "aws_s3_bucket_public_access_block" "cloudfront_logging" {
  bucket                  = aws_s3_bucket.cloudfront_logging.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## バージョニング設定
resource "aws_s3_bucket_versioning" "cloudfront_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

## 暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.bucket
  rule {
    object_ownership = "ObjectWriter"
  }
}

## ライフサイクルルール設定
resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logging" {
  bucket = aws_s3_bucket.cloudfront_logging.bucket
  rule {
    id     = "assets"
    status = "Enabled"
    ## 未完了なマルチパートアップロードの削除
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    ## オブジェクトの保存期間
    expiration {
      days = 30
    }
    ## 古いオブジェクトの保存期間
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}