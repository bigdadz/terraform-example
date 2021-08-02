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
  label = "test-web-server"
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


output "node_web_server_public_ip_address" {
  value = linode_instance.web.ip_address
}