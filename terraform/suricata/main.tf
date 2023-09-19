terraform {
  backend "gcs" {
    bucket  = "helm-backend-1018"
    prefix  = "helm/state-suricata"
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
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
        init_container {
          name    = "init-network-setup"
          image   = "busybox:latest"  # Using busybox for lightweight shell operations.
          command = ["/bin/sh", "-c", "interface=$(ip -o -4 route show to default | awk '{print $5}') && echo $interface > /tmp/interface-name && ip link set $interface promisc on"]

          volume_mount {
            name       = "interface-name"
            mount_path = "/tmp"
          }

          security_context {
            privileged = true  # Needed to alter network interfaces.
            capabilities {
              add = ["NET_ADMIN", "NET_RAW", "SYS_NICE"]
            }
          }
        }

        container {
          name  = "suricata"
          image = "harkirat101803/custom-suricata:${var.docker_tag}"

          args = ["/docker-entrypoint.sh", "-i", "$(cat /tmp/interface-name)"]

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
