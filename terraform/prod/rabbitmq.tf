
resource "helm_release" "rabbitmq" {
  name             = local.environment
  namespace        = "rabbitmq"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "rabbitmq"
  version          = "16.0.11"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

  set = [
    {
      name  = "auth.username"
      value = var.rabbitmq_user
    }
  ]

  set_sensitive = [
    {
      name  = "auth.password"
      value = var.rabbitmq_password
    }
  ]

  depends_on = [helm_release.longhorn]
}