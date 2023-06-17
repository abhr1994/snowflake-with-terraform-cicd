terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.66.2"
    }
  }

  # backend "s3" {
  #   bucket         = "<your-bucket-name>"
  #   key            = "terraform-staging.tfstate"
  #   region         = "<bucket-region>"
  #   # Optional DynamoDB for state locking. See https://developer.hashicorp.com/terraform/language/settings/backends/s3 for details.
  #   # dynamodb_table = "terraform-state-lock-table"
  #   encrypt        = true
  #   role_arn       = "arn:aws:iam::<your-aws-account-no>:role/<terraform-s3-backend-access-role>"
  # }

  backend "local" {
    path = "backend/terraform-staging.tfstate"
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