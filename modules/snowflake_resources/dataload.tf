resource "snowflake_file_format" "example_file_format" {
  name        = "AR_DEMO_CSV_FORMAT"
  database    = var.database
  schema      = "TF_DEMO"
  format_type = "CSV"
  field_delimiter = ","
  skip_header = 1
  field_optionally_enclosed_by = "\""
  empty_field_as_null = true
  null_if = ["NULL", "null"]
  compression = "AUTO"
  record_delimiter = "\n"
  binary_format                  = "HEX" 
  date_format                    = "AUTO" 
  encoding                       = "UTF8" 
  escape                         = "NONE" 
  escape_unenclosed_field        = "\\" 
  time_format                    = "AUTO" 
  timestamp_format               = "AUTO" 
}

resource "snowflake_file_format_grant" "grant" {
  database_name    = var.database
  schema_name      = "TF_DEMO"
  file_format_name = snowflake_file_format.example_file_format.name

  privilege = "USAGE"
  roles     = ["ACCOUNTADMIN","TF_DEMO_READER"]
}


resource "snowflake_storage_integration" "integration" {
  name    = "AR_AZURE_INT"
  comment = "Azure storage integration."
  type    = "EXTERNAL_STAGE"
  enabled = true
  storage_allowed_locations = ["azure://cicddatalake.blob.core.windows.net/iwx-cicddatalake/sample_data/"]
  storage_provider         = "AZURE"
  azure_tenant_id = "ebfb8680-a5f0-429d-979e-189595b7560f"
}

resource "snowflake_notification_integration" "integration" {
  name    = "MY_NOTIFICATION_INTEGRATION"
  comment = "A notification integration."
  enabled   = true
  type      = "QUEUE"
  # AZURE_STORAGE_QUEUE
  azure_storage_queue_primary_uri = "https://cicddatalake.queue.core.windows.net/snowpipequeue"
  azure_tenant_id                 = "ebfb8680-a5f0-429d-979e-189595b7560f"
}

resource "snowflake_stage" "example_stage" {
  name        = "MYSTAGE"
  database    = var.database
  schema      = "TF_DEMO"
  url = "azure://cicddatalake.blob.core.windows.net/iwx-cicddatalake/sample_data/"
  storage_integration = snowflake_storage_integration.integration.name
}


resource "snowflake_stage_grant" "grant_example_stage" {
  database_name = snowflake_stage.example_stage.database
  schema_name   = snowflake_stage.example_stage.schema
  roles         = ["ACCOUNTADMIN","TF_DEMO_READER"]
  privilege     = "USAGE"
  stage_name    = snowflake_stage.example_stage.name
}


resource "snowflake_pipe" "pipe" {
  depends_on = [ snowflake_table.demo_table ]
  database = var.database
  schema   = "TF_DEMO"
  name     = "STAGE_PIPE"
  comment = "A pipe."
  integration = snowflake_notification_integration.integration.name
  copy_statement = "copy into ${var.database}.TF_DEMO.DEMO_TABLE from @${var.database}.TF_DEMO.${snowflake_stage.example_stage.name} file_format = ${var.database}.TF_DEMO.${snowflake_file_format.example_file_format.name}"
  auto_ingest    = true
}
