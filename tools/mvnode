#!/bin/bash

# Get the current date in YYYYMMDD format
DATE=$(date +%Y%m%d)

# Get the current epoch time
EPOCH=$(date +%s)

# Define the new directory name
NEW_DIR_NAME="node_modules_${DATE}.${EPOCH}"

# Move the node_modules directory up one level and rename it
mv node_modules ../${NEW_DIR_NAME}

# Print a success message
echo "node_modules directory moved and renamed to ${NEW_DIR_NAME}"