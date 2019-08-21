resource "kubernetes_namespace" "app" {
  metadata {
    name = "${var.namespace}"
  }
}

# resource "kubernetes_config_map" "common" {
#   metadata {
#     name      = "common"
#     namespace = "${var.namespace}"
#   }

#   data = {
#     PGHOST = "pg"
#   }
# }

resource "kubernetes_secret" "appsecrets" {
  metadata {
    name      = "appsecrets"
    namespace = "${var.namespace}"
  }

  data = {
    PGPASSWORD        = "example-password"
    POSTGRES_PASSWORD = "example-password"
    APP_PGHOST        = "pg"
  }

  type = "Opaque"
}
