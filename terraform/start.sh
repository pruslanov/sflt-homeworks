#!/bin/bash

# Файл инвентаря Ansible
inventory_file="inventory.ini"

# Группа в файле инвентаря
group_name="yandex_cloud"

# Читаем username из meta.yaml
username=$(grep -oP '(?<=name: )\S+' meta.yml)

# Проверяем существует ли inventory file и удаляем старый
if [ -f "$inventory_file" ]; then
    rm "$inventory_file"
    echo "Old inventory file $inventory_file removed."
fi

# Запускаем terraform apply и проверяем exit code
if ! terraform apply -auto-approve; then
    echo "Terraform apply failed. Script execution stopped."
    exit 1
fi

# Запускаем terraform output и сохраняем внешние IP в массив
mapfile -t ip_addresses < <(terraform output -json | jq -r '.external_ip_addresses.value[]')

# Добавляем группу в файл инвентаря, если она еще не существует
if ! grep -qF "[$group_name]" "$inventory_file"; then
    echo -e "\n[$group_name]" >> "$inventory_file"
fi

base_hostname="host"
index=1

# Добавляем IP-адреса в файл инвентаря Ansible в указанную группу
for ip_address in "${ip_addresses[@]}"; do
    hostname="${base_hostname}${index}"
    # Проверяем, не содержится ли уже IP-адрес в файле
    if ! grep -qF "$ip_address" "$inventory_file"; then
        # Добавляем IP-адрес в файл и группу
        echo "$hostname ansible_host=$ip_address ansible_connection=ssh ansible_user=$username" >> "$inventory_file"
    fi
    ((index++))
done