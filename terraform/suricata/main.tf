terraform {
  backend "gcs" {
    bucket = "helm-backend-1018"
    prefix = "helm/state-suricata"
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_cluster_role" "suricata_role" {
  metadata {
    name = "suricata-listener-role"
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "delete"]
  }
}

resource "kubernetes_service_account" "suricata_sa" {
  metadata {
    name      = "suricata-service-account"
    namespace = "default" # or your desired namespace
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account" "suricata_sa" {
  metadata {
    name      = "suricata-service-account"
    namespace = "default"
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "suricata_role_binding" {
  metadata {
    name = "suricata-listener-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.suricata_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.suricata_sa.metadata[0].name
    namespace = "default"
  }
}



resource "kubernetes_daemonset" "suricata" {
  metadata {
    name = "suricata-daemonset"
  }

  spec {
    selector {
      match_labels = {
        name = "suricata"
      }
    }

    template {
      metadata {
        labels = {
          name = "suricata"
        }
      }

      spec {

        service_account_name = kubernetes_service_account.suricata_sa.metadata[0].name
        init_container {
          name    = "init-network-setup"
          image   = "busybox:latest" # Using busybox for lightweight shell operations.
          command = ["/bin/sh", "-c", "interface=$(ip -o -4 route show to default | awk '{print $5}') && echo $interface > /tmp/interface-name && ip link set $interface promisc on"]

          volume_mount {
            name       = "interface-name"
            mount_path = "/tmp"
          }

          security_context {
            privileged = true # Needed to alter network interfaces.
            capabilities {
              add = ["NET_ADMIN", "NET_RAW", "SYS_NICE"]
            }
          }
        }

        container {
          name  = "suricata"
          image = "harkirat101803/custom-suricata:${var.docker_tag}"

          command = ["/bin/sh", "-c", "interface=$(cat /tmp/interface-name) && ip link set $interface promisc on && /docker-entrypoint.sh -c /etc/suricata/suricata.yaml -i $interface"]

          env {
            name  = "INTERFACE"
            value = "" # Placehfolder value as Kubernetes doesn't directly support extracting arguments from another container.
          }

          volume_mount {
            name       = "logs"
            mount_path = "/var/log/suricata"
          }

          volume_mount {
            name       = "interface-name"
            mount_path = "/tmp"
          }

          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW", "SYS_NICE"]
            }
          }
        }

        container {
          name  = "suricata-listener"
          image = "harkirat101803/suricata-opa-listener"

          volume_mount {
            name       = "logs"
            mount_path = "/var/log/suricata"
          }

          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }
        }

        volume {
          name = "logs"
          empty_dir {
            medium = "Memory"
          }
        }

        volume {
          name = "interface-name"
          empty_dir {}
        }

        host_network = true
      }
    }
  }
}


