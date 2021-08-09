variable "nodes_space" {
  description = "Node for Cluster"
  type = map
  default = {
    node1 = {
      label = "node-1"
    }

    node2 = {
      label = "node-2"
    }

    node3 = {
      label = "node-3"
    }
  }
}