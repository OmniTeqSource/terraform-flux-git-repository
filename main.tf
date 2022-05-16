resource "random_string" "this" {
  keepers = {
    name = local.name
  }

  upper   = false
  special = false
  length  = 8
}

resource "helm_release" "this" {
  name       = join("-", [local.name, random_string.this.id])
  repository = "https://omniteqsource.github.io/charts"
  chart      = "null"
  values     = [yamlencode({ manifests = [local.manifest] })]
}

resource "tls_private_key" "this" {
  count = local.create_ssh_key ? 1 : 0

  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "kubernetes_secret" "this" {
  count = local.create_ssh_key ? 1 : 0

  depends_on = [helm_release.this]

  metadata {
    name        = local.secret_name
    namespace   = local.namespace
    annotations = {}
    labels      = {}
  }

  data = {
    identity       = tls_private_key.this[0].private_key_pem
    "identity.pub" = tls_private_key.this[0].public_key_pem
    known_hosts    = local.known_hosts_string
  }
}
