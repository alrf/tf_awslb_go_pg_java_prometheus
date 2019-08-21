resource "null_resource" "mandatory-ingress-nginx" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml"
  }
}

resource "kubernetes_service" "ingress-nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = "ingress-nginx"

    labels {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }

    annotations {
      "service.beta.kubernetes.io/aws-load-balancer-type"                    = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = "${var.acm}"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "443"
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "3600"
    }
  }

  spec {
    selector {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    port {
      name        = "https"
      protocol    = "TCP"
      port        = 443
      target_port = 80
    }

    type                    = "LoadBalancer"
    external_traffic_policy = "Local"
  }

  depends_on = ["null_resource.mandatory-ingress-nginx"]
}

// Workaround for Destroy
resource "null_resource" "destroy-mandatory-ingress-nginx" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml"
  }
}
