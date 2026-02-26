variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
  default     = "your-bucket-name"
}

variable "my_domain" {
  description = "The domain name for the CloudFront distribution."
  type        = string
  default     = "your-domain.name"
}

variable "cloudfront_alias" {
  description = "The CloudFront alias subdomain."
  type        = string
  default     = "your-cloudfront-alias"
}

variable "content_path" {
  description = "Path to the static content files to upload."
  type        = string
  default     = "the-content-path"
}

variable "environment" {
  description = "Environment name for tags."
  type        = string
  default     = "your-environment"
}
