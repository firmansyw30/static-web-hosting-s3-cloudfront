// Define local variables for reuse
locals {
  s3_origin_id = "myS3Origin"
  my_domain    = "your-domain.com" # Replace with your domain
}

data "aws_acm_certificate" "my_domain" {
  region   = "us-east-1" // change to actual region that hosted
  domain   = "*.${local.my_domain}"
  statuses = ["ISSUED"]
}

// Create S3 bucket for static website hosting
resource "aws_s3_bucket" "s3_bucket_name" {
  bucket = var.bucket_name

  tags = {
    Name = "My-Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.s3_bucket_name.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket_name.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket_name.id
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

resource "aws_s3_object" "s3_object" {
  for_each = fileset("${path.module}/../landing_page_cilicis/my-app/dist", "**") #change to project path (in this case the project dir is one level)
  bucket   = aws_s3_bucket.s3_bucket_name.id
  key      = each.value
  source   = "${path.module}/../landing_page_cilicis/my-app/dist/${each.value}" #change to dist/artifact path to be uploaded to s3 
  etag     = filemd5("${path.module}/../landing_page_cilicis/my-app/dist/${each.value}")
  //acl      = "public-read"
  content_type = lookup({
    "html"        = "text/html",
    "css"         = "text/css",
    "js"          = "application/javascript",
    "json"        = "application/json",
    "png"         = "image/png",
    "jpg"         = "image/jpeg",
    "jpeg"        = "image/jpeg",
    "gif"         = "image/gif",
    "ico"         = "image/x-icon",
    "svg"         = "image/svg+xml",
    "woff"        = "font/woff",
    "woff2"       = "font/woff2,",
    "ttf"         = "font/ttf",
    "eot"         = "application/vnd.ms-fontobject",
    "otf"         = "font/otf",
    "webmanifest" = "application/manifest+json",
    "xml"         = "text/xml",
    "pdf"         = "application/pdf",
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

// Create CloudFront distribution with S3 origin and OAC
resource "aws_cloudfront_origin_access_control" "default_oac" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket_name.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  aliases = ["app1.${local.my_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.my_domain.arn
    ssl_support_method  = "sni-only"
  }
}

# Create Route53 records for the CloudFront distribution aliases
data "aws_route53_zone" "my_domain" {
  name = local.my_domain
}

resource "aws_route53_record" "cloudfront" {
  for_each = aws_cloudfront_distribution.s3_distribution.aliases
  zone_id  = data.aws_route53_zone.my_domain.zone_id
  name     = each.value
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
