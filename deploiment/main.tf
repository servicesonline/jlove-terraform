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
    config_path    = "~/.kube/config"
}

locals {
    name = "jlove" 
    type = "webservers"
    container_name = "container-ssh"
}

resource "kubernetes_deployment" "my_deployment" {
    metadata {
        name = "${local.name}-deployment"
        namespace = "rashid"
        labels = {
            owner = local.name
            type = local.type
        }
    }
    spec {
        template {
            metadata {
                name = "${local.name}-pod"
                labels = {
                    owner = "${local.name}-pod"
                    app  = local.type
                }
            }
        
            spec {
                node_name = "master"
                container {
                    name = local.container_name
                    image = "ulrich0kelkun/ssh"
                }
            }
        }
        strategy {
            type = "RollingUpdate"
            rolling_update {
                max_surge       = "25%"
                max_unavailable = "25%"
            }
        }
        replicas = 3
        selector {
            match_labels = {
                owner = "${local.name}-pod"
                app = local.type
            }
        }
    }
}