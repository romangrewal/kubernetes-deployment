#!/bin/bash

# Project root
PROJECT_NAME="terraform-linode-namecheap"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

# Core Terraform files
touch main.tf variables.tf outputs.tf terraform.tfvars provider.tf versions.tf

# Ansible integration
touch ansible.sh setup.yml

# Optional modules and environments
mkdir -p modules/linode modules/dns env/dev env/prod

# README and .gitignore
cat <<EOF > README.md
# $PROJECT_NAME

Terraform project to provision Linode Nano server with CentOS Stream 9 and configure DNS via Namecheap. Includes Ansible provisioning.
EOF

cat <<EOF > .gitignore
# Terraform
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl

# Sensitive files
terraform.tfvars
*.pem
*.key
*.crt

# OS-specific
.DS_Store
Thumbs.db

# Ansible
*.retry
*.log
EOF

echo "✅ Project structure created: $PROJECT_NAME"

