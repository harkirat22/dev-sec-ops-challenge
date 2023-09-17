terraform {
  backend "gcs" {
    bucket  = "helm-backend-1018"
    prefix  = "helm/state"
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path 
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_namespace" "falco" {
  metadata {
    name = "falco"
  }
}

locals {
  syscalls = [
    "open", "openat", "read", "write", "pread", "preadv", "pwrite",
    "pwritev", "readv", "recv", "recvmmsg", "send", "sendfile",
    "sendmmsg", "writev", "socket", "bind", "connect", "setresuid",
    "setresgid", "setuid", "setgid", "setsid", "getuid", "getgid"
  ]
}

resource "helm_release" "falco" {
  depends_on = [kubernetes_namespace.falco]

  name          = "falco"
  chart         = "../../helm/falco-custom"
  namespace     = kubernetes_namespace.falco.metadata[0].name
  recreate_pods = true

  set {
    name  = "driver.kind"
    value = "ebpf"
  }

  set {
    name  = "tty"
    value = "true"
  }

  set {
    name  = "falcosidekick.enabled"
    value = "true"
  }

  set {
    name  = "dummy"
    value = "true"
}

 set {
    name  = "json_output"
    value = "true"
}
}
