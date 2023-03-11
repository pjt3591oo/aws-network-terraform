#!/bin/bash

function concat_strings {
  local mode="$1"
  local rst="./terraform/${1}/network"
  echo "${rst}" # return
}

directories=(
  $(concat_strings "dev")
  $(concat_strings "stage")
  $(concat_strings "prod")
)

for directory in "${directories[@]}"
do
  echo "Removing Terraform state and lock files for ${directory}..."
  
  rm -rf "${directory}/.terraform"
  rm -rf "${directory}/.terraform.lock.hcl"
  rm -rf "${directory}/terraform.tfstate"

  echo "Done removing Terraform state and lock files for ${directory}."
  echo ""
done