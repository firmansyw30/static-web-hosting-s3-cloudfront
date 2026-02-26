output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_aliases" {
  description = "The aliases configured for the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.aliases
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket_name.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket_name.arn
}

output "s3_domain_name" {
  description = "The regional domain name of the S3 bucket."
  value       = aws_s3_bucket.s3_bucket_name.bucket_regional_domain_name
}

output "route53_records" {
  description = "The Route53 records created for the CloudFront distribution."
  value = {
    for name, record in aws_route53_record.cloudfront : name => {
      fqdn = record.fqdn
      type = record.type
    }
  }
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate used by CloudFront."
  value       = data.aws_acm_certificate.my_domain.arn
}
