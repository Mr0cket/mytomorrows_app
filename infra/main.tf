resource "helm_release" "app" {
  name       = "mytomorrows-app"
  chart      = "./chart"
}
