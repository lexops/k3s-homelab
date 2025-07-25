
resource "helm_release" "meilisearch" {
  name             = local.environment
  namespace        = "meilisearch"
  repository       = "https://meilisearch.github.io/meilisearch-kubernetes"
  chart            = "meilisearch"
  version          = "0.14.0"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

  set = [
    {
      name  = "persistence.enabled"
      value = true
    },
    {
      name  = "environment.MEILI_ENV"
      value = "production"
    }
  ]

  set_sensitive = [
    {
      name  = "environment.MEILI_MASTER_KEY"
      value = var.meili_master_key
    }
  ]

  depends_on = [helm_release.longhorn]
}