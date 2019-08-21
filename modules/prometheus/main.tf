resource "kubernetes_config_map" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "${var.namespace}"
  }

  data = {
    "prometheus.yml" = "${file("${path.module}/prometheus.yaml")}"
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "${var.namespace}"

    labels = {
      app = "prometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          image = "prom/prometheus"
          name  = "prometheus"

          args = [
            "--config.file=/etc/prometheus/prometheus.yml",
            "--web.external-url=/monitoring",
          ]

          port {
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = "prometheus"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "${var.namespace}"
  }

  spec {
    selector {
      app = "prometheus"
    }

    port {
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }
  }
}
