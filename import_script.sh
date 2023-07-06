#!/bin/bash

# Check if resource exists in state
STORAGE_EXISTS=$(terraform -chdir=./$1 state list | grep "module.snowflake_resources.snowflake_storage_integration.integration")
NOTIFICATION_EXISTS=$(terraform -chdir=./$1  state list | grep "module.snowflake_resources.snowflake_notification_integration.integration")

# Import the resource if it doesn't exist
if [ -z "$STORAGE_EXISTS" ]; then
  echo "Storage Resource does not exist in state. Importing..."
  terraform -chdir=./$1  import module.snowflake_resources.snowflake_storage_integration.integration AR_AZURE_INT
else
  echo "Storage Resource already exists in state. Skipping import."
fi
if [ -z "$STORAGE_EXISTS" ]; then
  echo "Notification Integration Resource does not exist in state. Importing..."
  terraform -chdir=./$1 import module.snowflake_resources.snowflake_notification_integration.integration MY_NOTIFICATION_INTEGRATION
else
  echo "Notification Integration Resource already exists in state. Skipping import."
fi