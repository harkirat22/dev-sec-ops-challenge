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
          }
        }

        container {
          name  = "suricata"
          image = "harkirat101803/custom-suricata:${var.docker_tag}"

          args = [
            "-i", "$(INTERFACE)"
          ]

          env {
            name  = "INTERFACE"
            value_from {
              field_ref {
                field_path = "spec.containers[?(@.name=='init-network-setup')].args[0]"  # Extract interface name from init container.
              }
            }
          }

          volume_mount {
            name       = "logs"
            mount_path = "/var/log/suricata"
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
