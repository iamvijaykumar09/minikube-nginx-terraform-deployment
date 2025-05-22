#Configuring Kubernetes Provider
provider "kubernetes" {
  config_path = "/home/vijay/.kube/config"
}

#Defining the Nginx Deployment
resource "kubernetes_deployment_v1" "nginx_deployment" {
  metadata {
    name = "nginx-deployment"
    labels = {
      app = "nginx"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

#defining the Nginx Service
resource "kubernetes_service_v1" "nginx-service" {
  metadata {
    name = "nginx-service"
    labels = {
      app = "nginx"
    }
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}
