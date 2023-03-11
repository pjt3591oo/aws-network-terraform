MODE="prod"

BASE_PATH="terraform/${MODE}"

cd ${BASE_PATH}

terraform init

terraform apply -auto-approve
