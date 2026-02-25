output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "web_server_ips" {
  description = "Public IPs of web servers"
  value       = module.web_servers.public_ips
}

output "database_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_instance_endpoint
}

output "cdn_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.distribution_domain_name
}

output "static_assets_bucket" {
  description = "S3 bucket for static assets"
  value       = module.static_assets.bucket_id
}
