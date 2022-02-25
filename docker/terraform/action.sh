#!/usr/bin/env sh

echo "Current dir is: $(pwd)"

echo "Moving prepared .terraform..."
mv /workspace/.terraform ./

echo "Updating terraform dependencies just for safety:"
terraform init

echo "Running terraform command"

terraform "${@}"
