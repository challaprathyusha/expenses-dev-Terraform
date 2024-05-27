#!/bin/bash
dnf install ansible -y
cd /tmp
git clone https://github.com/challaprathyusha/ansible-roles.git
cd ansible-roles
ansible-playbook main.yaml -e COMPONENT=backend -e mysql_password=ExpenseApp1
ansible-playbook main.yaml -e COMPONENT=frontend