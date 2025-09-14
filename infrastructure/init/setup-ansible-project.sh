#!/bin/bash

# Project name
PROJECT="appsec-ansible"
mkdir -p "$PROJECT"
cd "$PROJECT" || exit

echo "📁 Creating simplified Ansible project: $PROJECT"

# Create core files and folders
mkdir -p roles/nginx/{templates,files}
touch ansible.cfg inventory.yml playbook.yml
touch roles/nginx/{tasks.yml,handlers.yml,vars.yml}

# ansible.cfg
cat <<EOF > ansible.cfg
[defaults]
inventory = inventory.yml
roles_path = roles
EOF

# inventory.yml
cat <<EOF > inventory.yml
all:
  hosts:
    web01:
      ansible_host: 192.168.1.10
      ansible_user: ubuntu
EOF

# playbook.yml
cat <<EOF > playbook.yml
- name: Deploy Nginx
  hosts: web01
  become: yes
  roles:
    - nginx
EOF

# tasks.yml
cat <<EOF > roles/nginx/tasks.yml
- name: Install Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Deploy config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx
EOF

# handlers.yml
cat <<EOF > roles/nginx/handlers.yml
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
EOF

# vars.yml
echo "nginx_port: 80" > roles/nginx/vars.yml

# nginx.conf.j2
cat <<EOF > roles/nginx/templates/nginx.conf.j2
user www-data;
worker_processes auto;
pid /run/nginx.pid;
events {
    worker_connections 768;
}
http {
    server {
        listen {{ nginx_port }};
        location / {
            root /var/www/html;
            index index.html;
        }
    }
}
EOF

# index.html
echo "<h1>Welcome to AppSec Academy</h1>" > roles/nginx/files/index.html

echo "✅ Simplified Ansible project created successfully."

