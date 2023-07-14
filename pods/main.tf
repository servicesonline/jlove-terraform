terraform {
  backend "kubernetes" {
    secret_suffix    = "jlove"
    config_path      = "~/.kube/config"
    namespace = "rashid"
  }
}

data "terraform_remote_state" "jlove" {
  backend = "kubernetes"
  config = {
    secret_suffix    = "jlove"
    config_path = "~/.kube/config"
    namespace = "rashid"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}



variable "container" {
  type = list (object({
    container_name = string
    pod_name = string
  }))


  default = [{
          container_name = "container1"
          pod_name = "jlove-ssh-pod1"
      },
      {
          container_name = "container2"
          pod_name = "jlove-ssh-pod2"
      },
      {
          container_name = "container3"
          pod_name = "jlove-ssh-pod3"
      }
  ]
}

# locals {
#   owner = "jlove"
#   app = "ssh"
# }



resource "kubernetes_pod_v1" "jlove-pod" {
  count = length(var.container)

  metadata {
    name = var.container[count.index].pod_name
    namespace = "rashid"
    labels = {
      owner = "jlove"
      type = "ssh"
    }
  }

  spec {
    node_name = "master"
    container {
      name = var.container[count.index].container_name
      image = "ulrich0kelkun/ssh"
    }
  }
  # selector {
  #   match_labels = {
  #     owner = "${local.owner}-pod"
  #     app = local.type
  #   }
  # }
}

