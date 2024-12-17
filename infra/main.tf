variable "app_config" {
  type = map(string)
  default = {}
}

variable "app_secrets" {
  type = map(string)
  default = {}
  sensitive = true
}


resource "helm_release" "app" {
  name       = "mytomorrows-app"
  chart      = "./chart"

  dynamic "set" {
    for_each = var.app_config
    content {
      name  = "envConfigs.${set.key}"
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = var.app_secrets
    content {
      name = "envSecrets.${set_sensitive.key}"
      value = set_sensitive.value
    }
  }
}
