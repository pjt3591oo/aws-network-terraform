MODE="prod"

BASE_PATH="terraform/${MODE}/network"

cd ${BASE_PATH}

terraform init

terraform apply -auto-approve
