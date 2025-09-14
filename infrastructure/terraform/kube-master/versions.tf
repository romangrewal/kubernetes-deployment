terraform {
  required_version = ">= 1.13.1"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
  }
}

