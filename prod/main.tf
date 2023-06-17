terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.66.2"
    }
  }

backend "local" {
    path = "backend/terraform-prod.tfstate"
  }

provider "snowflake" {
  username    = "CICD_DEPLOYER"
  account     = "infoworks_partner"
  role        = "ACCOUNTADMIN"
  private_key = var.snowflake_private_key
}


module "snowflake_resources" {
  source              = "../modules/snowflake_resources"
  time_travel_in_days = 30
  database            = var.database
  env_name            = var.env_name
}