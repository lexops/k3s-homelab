
resource "helm_release" "postgresql" {
  name             = local.environment
  namespace        = "postgresql"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  version          = "16.7.20"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

  set = [
    {
      name  = "auth.username"
      value = var.postgresql_user
    }
  ]

  set_sensitive = [
    {
      name  = "auth.password"
      value = var.postgresql_password
    }
  ]

  depends_on = [ helm_release.longhorn ]
}