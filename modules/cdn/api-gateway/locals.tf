locals {
  common_tags = merge(
    {
      Module      = "api-gateway"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  name_prefix = "${var.name}-${var.environment}"

  # Flatten resources and methods for iteration
  resource_methods = flatten([
    for res_key, res in var.resources : [
      for method_key, method in res.methods : {
        resource_key     = res_key
        method_key       = method_key
        path_part        = res.path_part
        http_method      = method.http_method
        authorization    = method.authorization
        authorizer_key   = method.authorizer_key
        integration_type = method.integration_type
        integration_uri  = method.integration_uri
      }
    ]
  ])
}
