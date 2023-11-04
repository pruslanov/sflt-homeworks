#!/bin/bash

# Run Terraform destroy and check the exit code
if ! terraform destroy -auto-approve; then
    echo "Terraform destroy failed. Script execution stopped."
    exit 1
fi

# Ansible inventory file
inventory_file="inventory.ini"

# Check if the inventory file exists and remove it
if [ -f "$inventory_file" ]; then
    rm "$inventory_file"
    echo "Inventory file $inventory_file removed."
else
    echo "Inventory file $inventory_file does not exist."
fi