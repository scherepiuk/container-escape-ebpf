.PHONY: init deploy ssh teardown

init:
	terraform -chdir=terraform init

deploy: init
	terraform -chdir=terraform apply
	@terraform -chdir=terraform output ssh_command

ssh:
	@bash -c "$$(terraform -chdir=terraform output -raw ssh_command)"

teardown:
	terraform -chdir=terraform destroy -auto-approve
