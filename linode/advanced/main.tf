terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
    }
  }
}

provider "linode" {
  token = "<-------paste your token------->"
}

resource "linode_instance" "web" {
  for_each = var.nodes_space
  label = each.value.label
  image = "linode/ubuntu20.04"
  region = "ap-south"
  type = "g6-standard-1"
  # authorized_keys = ["ssh-rsa AAAA...Gw== user@example.local"]
  # authorized_users = ["user"]
  root_pass = "<-------paste your password------->"

  group = "Test"
  tags = ["Test"]
  swap_size = 2048
  private_ip = true
}
