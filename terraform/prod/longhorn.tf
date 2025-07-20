

resource "helm_release" "longhorn" {
  name             = local.environment
  namespace        = "longhorn-system"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  version          = "1.9.0"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true

}