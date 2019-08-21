resource "kubernetes_deployment" "pg" {
  metadata {
    name      = "pg"
    namespace = "${var.namespace}"

    labels = {
      app = "pg"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "pg"
      }
    }

    template {
      metadata {
        labels = {
          app = "pg"
        }
      }

      spec {
        container {
          image = "launcher.gcr.io/google/postgresql9"
          name  = "postgres"

          port {
            container_port = 5432
          }

          env_from {
            secret_ref {
              name = "appsecrets"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pg" {
  metadata {
    name      = "pg"
    namespace = "${var.namespace}"
  }

  spec {
    selector {
      app = "pg"
    }

    port {
      protocol    = "TCP"
      port        = 5432
      target_port = 5432
    }
  }
}
