variable "aws_region" {
  type    = string
  default = "ap-east-1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "sentry_auth_token" {
  description = "Sentry personal authentication token. The token must have `admin` access to the project scope."
  type        = string
}

variable "aws_cache_paths" {
  description = "List of cache paths"
  type        = list(string)
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "dev_domain_name" {
  description = "Domain for dev environment"
  type        = string
}

variable "uat_domain_name" {
  description = "Domain for uat environment"
  type        = string
}
