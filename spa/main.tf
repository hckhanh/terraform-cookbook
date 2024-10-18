terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72.0"
    }

    sentry = {
      source  = "jianyuan/sentry"
      version = "~> 0.12.1"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "aws" {
  alias      = "acm"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "sentry" {
  token = var.sentry_auth_token
}

resource "sentry_key" "admin" {
  organization = var.sentry_org
  project      = var.sentry_project
  name         = "Security Headers"
}

data "aws_acm_certificate" "admin" {
  domain      = "*.${var.domain_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
  provider    = aws.acm
}

data "aws_route53_zone" "admin" {
  name = "${var.domain_name}."
}

locals {
  types = ["A", "AAAA"]
}
