resource "kubernetes_deployment" "go" {
  metadata {
    name      = "go"
    namespace = "${var.namespace}"

    labels = {
      app = "go"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "go"
      }
    }

    template {
      metadata {
        labels = {
          app = "go"
        }
      }

      spec {
        container {
          image             = "alrf/go-web-app:latest"
          name              = "go"
          image_pull_policy = "Always"

          port {
            container_port = 8080
          }

          env_from {
            # config_map_ref {  #   name = "common"  # }

            secret_ref {
              name = "appsecrets"
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "go" {
  metadata {
    name      = "go"
    namespace = "${var.namespace}"
  }

  spec {
    selector {
      app = "go"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress" "go-pg" {
  metadata {
    annotations {
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
    }

    name      = "go-pg"
    namespace = "${var.namespace}"
  }

  spec {
    rule {
      host = "${var.domain}"

      http {
        path {
          backend {
            service_name = "go"
            service_port = 8080
          }

          path = "/metrics"
        }

        path {
          backend {
            service_name = "prometheus"
            service_port = 9090
          }

          path = "/monitoring"
        }
      }
    }
  }
}
