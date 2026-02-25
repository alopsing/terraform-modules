################################################################################
# Three-Tier Web Application
#
# Architecture:
#   CloudFront -> EC2 (Web/App Tier) -> RDS (Data Tier)
#   S3 for static assets served via CloudFront
#
# Modules used: VPC, EC2, RDS, S3, CloudFront
################################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

################################################################################
# Networking
################################################################################

module "vpc" {
  source = "../../modules/networking/vpc"

  name        = var.project_name
  environment = var.environment
  cidr_block  = "10.0.0.0/16"

  azs                  = var.azs
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = var.environment != "prod"
  enable_flow_logs   = var.environment == "prod"

  tags = var.tags
}

################################################################################
# Web/App Tier — EC2
################################################################################

module "web_servers" {
  source = "../../modules/compute/ec2"

  name        = "${var.project_name}-web"
  environment = var.environment

  instance_count      = var.web_instance_count
  instance_type       = var.web_instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  vpc_id              = module.vpc.vpc_id
  associate_public_ip = true

  root_volume_size      = 30
  root_volume_encrypted = true

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    },
  ]

  tags = var.tags
}

################################################################################
# Data Tier — RDS
################################################################################

module "database" {
  source = "../../modules/storage/rds"

  name        = var.project_name
  environment = var.environment
  identifier  = "${var.project_name}-${var.environment}"

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = replace(var.project_name, "-", "_")
  username = "app_admin"

  multi_az            = var.environment == "prod"
  subnet_ids          = module.vpc.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = ["10.0.0.0/16"]

  backup_retention_period = var.environment == "prod" ? 30 : 7
  deletion_protection     = var.environment == "prod"
  skip_final_snapshot     = var.environment != "prod"

  tags = var.tags
}

################################################################################
# Static Assets — S3
################################################################################

module "static_assets" {
  source = "../../modules/storage/s3"

  name        = var.project_name
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-static-assets"

  enable_versioning = true
  encryption_type   = "SSE-S3"

  tags = var.tags
}

################################################################################
# CDN — CloudFront
################################################################################

module "cdn" {
  source = "../../modules/cdn/cloudfront"

  name        = var.project_name
  environment = var.environment
  comment     = "${var.project_name} CDN distribution"

  default_root_object = "index.html"
  price_class         = var.environment == "prod" ? "PriceClass_All" : "PriceClass_100"

  origins = [
    {
      domain_name          = module.static_assets.bucket_regional_domain_name
      origin_id            = "s3-static"
      origin_type          = "s3"
      s3_origin_config     = {}
      custom_origin_config = null
    },
  ]

  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-static"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = null
    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  create_oac = true

  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 300
    },
  ]

  tags = var.tags
}
