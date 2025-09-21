[kube-workers]
${name_worker_one} ansible_user=root ansible_host=${ip_worker_one} ansible_ssh_private_key_file=~/.ssh/id_rsa
${name_worker_two} ansible_user=root ansible_host=${ip_worker_two} ansible_ssh_private_key_file=~/.ssh/id_rsa

