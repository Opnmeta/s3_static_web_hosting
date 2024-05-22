##########################
### AWS provider
##########################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = local.config.global.region
  profile = local.config.provider_info.assume_role.profile
  assume_role {
    role_arn = local.config.provider_info.assume_role.main.main_role
    session_name = "CI_DEPLOY"
  }
  skip_requesting_account_id = true
}


provider "aws" {
  alias   = "main"
  region  = local.config.provider_info.assume_role.main.main_region
  profile = local.config.provider_info.assume_role.profile
  default_tags {
    tags = local.common_tags
  }
  assume_role {
    role_arn = local.config.provider_info.assume_role.main.main_role
    session_name = "CI_DEPLOY"
  }
  skip_requesting_account_id = true
}

provider "aws" {
  alias   = "use1"
  region  = "us-east-1"
  profile = local.config.provider_info.assume_role.profile
  default_tags {
    tags = local.common_tags
  }
  assume_role {
    role_arn = local.config.provider_info.assume_role.main.main_role
    session_name = "CI_DEPLOY"
  }
  skip_requesting_account_id = true
}


