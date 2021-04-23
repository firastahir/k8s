resource "kubernetes_deployment" "app" {
  metadata {
    name      = "deployment-2048"
    labels    = {
      app = "2048"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "2048"
      }
    }

    template {
      metadata {
        labels = {
          app = "2048"
        }
      }

      spec {
        container {
          image = "598202605839.dkr.ecr.us-west-2.amazonaws.com/demo/api:2048"
          name  = "2048"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-2048"
  }
  spec {
    selector = {
      app = "2048"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}

resource "kubernetes_ingress" "app" {
  metadata {
    name      = "2048-ingress"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internal"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
        "app" = "2048-ingress"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "service-2048"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}