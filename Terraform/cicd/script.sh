#!/bin/bash
set -e

PUBLIC_IP=$1

echo "Received public IP: $PUBLIC_IP"
echo "Waiting for SSH to become available on $PUBLIC_IP..."

# Wait for port 22 (SSH) to be available
while ! nc -z $PUBLIC_IP 22; do
  echo "Waiting for SSH on $PUBLIC_IP..."
  sleep 5
done

echo "SSH is available. Generating dynamic Ansible inventory...."
cd /home/mahmoud/final_project_konecta/Konecta_Final_Task/ansible

rm inventory.ini
cat <<EOF > inventory.ini
[jenkins]
$PUBLIC_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ci_cd_key  ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF


# Create temporary inventory file
echo "Running Ansible playbook..."
ansible-playbook -i inventory.ini playbook.yml
