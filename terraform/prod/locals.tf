locals {
  environment = "${basename(path.cwd)}"
  user        = "${local.environment}-user"
}
