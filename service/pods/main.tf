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


locals {
  owner = "jlove"
  type = "ssh"
}


resource "kubernetes_service_v1" "pods_service" {
  metadata {
    name = "jlove-pod-service"
    namespace = "rashid"
  }
  spec {
    selector = {
      app = local.type
    }
    # session_affinity = "ClientIP"
    port {
      port        = 8989
      target_port = 22
      node_port = 30089
      name = "ssh-port"
    }

    type = "NodePort"
  }
}