terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.66.2"
    }
  }

    backend "azurerm" {
    resource_group_name = "iw-azure-cs-db-cluster"
    storage_account_name = "cicddatalake"
    container_name       = "tfstate"
    key                  = "terraform-staging.tfstate"
  }

}

provider "snowflake" {
  username    = "CICD_DEPLOYER"
  account     = "infoworks_partner"
  role        = "ACCOUNTADMIN"
  private_key = var.snowflake_private_key
}

module "snowflake_resources" {
  source              = "../modules/snowflake_resources"
  time_travel_in_days = 1
  database            = var.database
  env_name            = var.env_name
}