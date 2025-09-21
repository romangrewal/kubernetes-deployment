provider "linode" {
  token = var.linode_token
}

###################################################################
########################### Worker 1 ##############################
###################################################################

resource "linode_firewall" "firewall-kube-worker-1" {
  label = "kube-worker-1-firewall"
  
  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"

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
    label    = "allow-metallb-speaker-node-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "7946"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  
  inbound {
    label    = "allow-metallb-speaker-node-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "7946"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kube-api-port"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10250"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kube-proxy-port"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10256"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-nodeport-services-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-nodeport-services-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "30000-32767"
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

  linodes = [linode_instance.nano-kube-worker-1.id]

}

resource "linode_instance" "nano-kube-worker-1" {
  label      = "centos-stream-9-kube-worker-1"
  type       = "g6-nanode-1"
  region     = var.linode_region
  image      = "linode/centos-stream9"
  tags       = ["terraform", "centos"]
  authorized_keys = [chomp(file("~/.ssh/id_rsa.pub"))]
}

###################################################################
########################### Worker 2 ##############################
###################################################################

resource "linode_firewall" "firewall-kube-worker-2" {
  label = "kube-worker-2-firewall"
  
  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"

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
    label    = "allow-metallb-speaker-node"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "7946"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kube-api-port"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10250"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-kube-proxy-port"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10256"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-metallb-speaker-node-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "7946"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  
  inbound {
    label    = "allow-metallb-speaker-node-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "7946"
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

  linodes = [linode_instance.nano-kube-worker-2.id]

}

resource "linode_instance" "nano-kube-worker-2" {
  label      = "centos-stream-9-kube-worker-2"
  type       = "g6-nanode-1"
  region     = var.linode_region
  image      = "linode/centos-stream9"
  tags       = ["terraform", "centos"]
  authorized_keys = [chomp(file("~/.ssh/id_rsa.pub"))]
}

###################################################################
########################### Inventory #############################
###################################################################

locals {
  worker_one_ip = tolist(linode_instance.nano-kube-worker-1.ipv4)
  worker_two_ip = tolist(linode_instance.nano-kube-worker-2.ipv4)
}

locals {
  existing_content = fileexists("${path.module}/../../ansible/inventory.ini") ? file("${path.module}/../../ansible/inventory.ini") : ""
  new_line_to_add  = templatefile("${path.module}/inventory.tpl", {
    ip_worker_one = local.worker_one_ip[0]
    ip_worker_two = local.worker_two_ip[0]
  })
  combined_content = "${local.existing_content}${local.new_line_to_add}"
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../ansible/inventory.ini"
  content  = local.combined_content
}
