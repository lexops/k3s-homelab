resource "kubernetes_namespace" "scylladb" {
  metadata {
    name = "scylladb"
  }
}

resource "kubernetes_config_map" "scylladb" {
  metadata {
    name      = "scylladb-migration"
    namespace = kubernetes_namespace.scylladb.metadata[0].name
  }

  data = {
    "init.cql" = file("../../scripts/init.cql")
  }
}

resource "helm_release" "scylladb" {
  name             = local.environment
  namespace        = "scylladb"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "scylladb"
  version          = "5.0.1"
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true

  set = [
    {
      name  = "initDBConfigMap"
      value = kubernetes_config_map.scylladb.metadata[0].name
    },
    {
      name  = "dbUser.user"
      value = var.scylladb_user
    }
  ]

  set_sensitive = [
    {
      name  = "dbUser.password"
      value = var.scylladb_password
    }
  ]

  depends_on = [helm_release.longhorn]
}