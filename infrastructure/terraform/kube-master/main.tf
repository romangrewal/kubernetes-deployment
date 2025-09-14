provider "linode" {
  token = var.linode_token
}

resource "linode_firewall" "firewall" {
  label = "kube-master-firewall"
  
  inbound_policy = "DROP"     # or "ACCEPT"
  outbound_policy = "ACCEPT"  # required too
  
  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  
  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kube-control-plane"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "6443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kubelet-api"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10250"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-ping"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["0::/0"]
  }

  linodes = [linode_instance.nano.id]

}


resource "linode_instance" "nano" {
  label      = "centos-stream-9-kube-master"
  type       = "g6-standard-2"
  region     = var.linode_region
  image      = "linode/centos-stream9"
  tags       = ["terraform", "centos"]
  authorized_keys = [chomp(file("~/.ssh/id_rsa.pub"))]
}

#resource "linode_sshkey" "admin_ssh_key" {
#  label   = "admin-ssh-key"
#  ssh_key = chomp(file("~/.ssh/id_rsa.pub")) # Replace with your public key path
#}

locals {
  linode_ip = tolist(linode_instance.nano.ipv4)
}

locals {
  existing_content = fileexists("${path.module}/../../ansible/inventory.ini") ? file("${path.module}/../../ansible/inventory.ini") : ""
  new_line_to_add  = templatefile("${path.module}/inventory.tpl", {
    ip = local.linode_ip[0]
  })
  combined_content = "${local.existing_content}${local.new_line_to_add}"
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory.ini"
  content  = local.combined_content
}

