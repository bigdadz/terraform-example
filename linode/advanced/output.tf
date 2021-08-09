output "node_web_server_public_ip_address" {
  value = {
    for instance in linode_instance.web:
      instance.label => instance.ip_address
  }
}