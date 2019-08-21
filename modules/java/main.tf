resource "kubernetes_deployment" "java" {
  metadata {
    name      = "java"
    namespace = "${var.namespace}"

    labels = {
      app = "java"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "java"
      }
    }

    template {
      metadata {
        labels = {
          app = "java"
        }
      }

      spec {
        container {
          image   = "bitnami/java-example:0.0.1"
          name    = "java"
          command = ["java", "-jar", "jenkins.war"]
          args    = ["-Xmx1G"]

          port {
            container_port = 8080
          }

          resources {
            limits {
              memory = "1Gi"
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "java" {
  metadata {
    name      = "java"
    namespace = "${var.namespace}"
  }

  spec {
    selector {
      app = "java"
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 8080
    }
  }
}
