resource "aws_s3_bucket" "site" {
  bucket = "${var.project}-${var.env}-site-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# --- CloudFront OAC for S3 ---
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "${var.project}-${var.env}-s3-oac"
  description                       = "OAC for CloudFront to access S3 media bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- Updated S3 Bucket Policy (allow CloudFront only via OAC) ---
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json
}

data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontAccess"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

# --- CloudFront Distribution ---
resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.env} CloudFront"

  # --- Origin: S3 (media assets) ---
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # --- Origin: ALB (app) ---
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # --- Default Behavior (App backend) ---
  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "allow-all" # allow both HTTP and HTTPS
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  # --- Behavior for media files (/media/*) ---
  ordered_cache_behavior {
    path_pattern           = "/media/*"
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
