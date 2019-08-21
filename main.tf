variable "namespace" {}
variable "domain" {}
variable "acm" {}

module "aws-ingress-nginx" {
  source = "./modules/aws-ingress-nginx/"
  acm    = "${var.acm}"
}

module "common" {
  source    = "./modules/common/"
  namespace = "${var.namespace}"
}

module "prometheus" {
  source    = "./modules/prometheus/"
  namespace = "${var.namespace}"
}

module "pg" {
  source    = "./modules/pg/"
  namespace = "${var.namespace}"
}

module "java" {
  source    = "./modules/java/"
  namespace = "${var.namespace}"
}

module "go" {
  source    = "./modules/go/"
  namespace = "${var.namespace}"
  domain    = "${var.domain}"
}
