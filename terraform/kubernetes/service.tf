resource "kubernetes_service" "fuel_api_service" {
  metadata {
    name = "fuel-api"
  }

  spec {
    selector = {
      app = "fuel-api"
    }
    port {
      port        = 5000
      target_port = 5000
    }
    type = "NodePort"
  }
}
