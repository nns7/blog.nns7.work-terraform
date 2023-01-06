# --------------------------------
# Origin Access Control用ポリシー
data "aws_iam_policy_document" "s3_hugo_policy" {
  ## CloudFront Distributionからのアクセスのみ許可
  statement {
    ## アクセス元の設定
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    ## バケットに対して許可するアクション
    actions = ["s3:GetObject"] ## GetObjectのみ許可

    ## アクセス先の設定
    resources = [
      "${aws_s3_bucket.hugo.arn}",
      "${aws_s3_bucket.hugo.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.hugo.arn]
    }
  }
}

# --------------------------------
# OpenID Connect ID Provider
data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

# --------------------------------
# GitHub Actions用IAMロール
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_account}/${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "hugo_s3_push" {
  statement {
    actions = ["s3:ListBucket", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.hugo.arn}",
      "${aws_s3_bucket.hugo.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "hugo_s3_push" {
  name   = "hugo-s3-push"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.hugo_s3_push.json
}