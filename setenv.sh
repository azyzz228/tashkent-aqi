#!/bin/bash

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: source setenv.sh <env_file>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: File not found: $1"
  exit 1
fi

# Read the file line by line and set environmental variables
while IFS= read -r line; do
  export "$line"
done < "$1"

echo "Environmental variables set from $1"
