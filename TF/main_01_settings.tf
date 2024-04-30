variable CONFIG {}

locals {
    config              = yamldecode(file(var.CONFIG))
}


locals {
  common_tags = {
    Customer         = local.config.resources_tags.customer_name
    Customer_Name    = local.config.resources_tags.customer_name
    Customer_Short   = local.config.resources_tags.customer_short
    Domain           = local.config.resources_tags.hostname_domain
    Project          = local.config.resources_tags.project_name
    Project_Short    = local.config.resources_tags.project_short
    Project_Number   = local.config.resources_tags.project_number
  }
}


