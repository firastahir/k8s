resource "kubernetes_namespace" "eksdemo-ns" {
  metadata {
    name = "eksdem-ns"
  }
}

resource "aws_eks_fargate_profile" "ecsdemo-profile" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "ecsdemo-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.secondary_subnet_ids

  selector {
    namespace = kubernetes_namespace.ecsdemo-ns.id
  }
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "kubernetes_deployment" "crystal" {
  metadata {
    name      = "deployment-crystal"
    namespace = kubernetes_namespace.ecsdemo-ns.id
    labels    = {
      app = "ecsdemo-crystal"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ecsdemo-crystal"
      }
    }

    template {
      metadata {
        labels = {
          app = "ecsdemo-crystal"
        }
      }

      spec {
        container {
          image = "598202605839.dkr.ecr.us-west-2.amazonaws.com/dj:crystal"
          name  = "ecsdemo-crystal"

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "crystal" {
  metadata {
    name      = "ecsdemo-crystal"
  }
  spec {
    selector = {
      app = "ecsdemo-crystal"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.crystal]
}

resource "kubernetes_deployment" "nodejs" {
  metadata {
    name      = "deployment-nodejs"
    namespace = kubernetes_namespace.ecsdemo-ns.id
    labels    = {
      app = "ecsdemo-nodejs"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ecsdemo-nodejs"
      }
    }

    template {
      metadata {
        labels = {
          app = "ecsdemo-nodejs"
        }
      }

      spec {
        container {
          image = "598202605839.dkr.ecr.us-west-2.amazonaws.com/dj:nodejs"
          name  = "ecsdemo-nodejs"

          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nodejs" {
  metadata {
    name      = "ecsdemo-nodejs"
  }
  spec {
    selector = {
      app = "ecsdemo-nodejs"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.nodejs]
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "deployment-frontend"
    namespace = kubernetes_namespace.ecsdemo-ns.id
    labels    = {
      app = "ecsdemo-frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ecsdemo-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "ecsdemo-frontend"
        }
      }

      spec {
        container {
          image = "598202605839.dkr.ecr.us-west-2.amazonaws.com/dj:frontend"
          name  = "ecsdemo-frontend"

          port {
            container_port = 3000
          }
          env {
            name = "CRYSTAL_URL"
            value = "http://ecsdemo-crystal.eksdemo-ns.svc.cluster.local/crystal"
          }
          env {
            name = "NODEJS_URL"
            value = "http://ecsdemo-nodejs.eksdemo-ns.svc.cluster.local/"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "ecsdemo-frontend"
  }
  spec {
    selector = {
      app = "ecsdemo-frontend"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.frontend]
}



resource "kubernetes_ingress" "frontend" {
  metadata {
    name      = "nginx-ingress"
    annotations = {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internal"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
    labels = {
        "app" = "ecsdemo-frontend"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "ecsdemo-frontend"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.frontend]
}