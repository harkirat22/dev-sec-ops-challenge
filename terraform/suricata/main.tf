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
          command = ["/bin/sh", "-c", "interface=$(ip -o -4 route show to default | awk '{print $5}') && ip link set $interface promisc on"]

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

        command = ["/docker-entrypoint.sh"]
        args = ["-i", "$(cat /tmp/interface-name)"]  # Using the interface from the shared file.

        security_context {
            capabilities {
                add = ["NET_ADMIN", "NET_RAW", "SYS_NICE"]
            }
        }
        volume_mount {
            name       = "logs"
            mount_path = "/var/log/suricata"
        }
        volume_mount {
            name       = "interface-name"
            mount_path = "/tmp"
        }
    }

        volume {
          name = "logs"
          empty_dir {
            medium = "Memory"
          }
        }

        host_network = true
      }
    }
  }
}
