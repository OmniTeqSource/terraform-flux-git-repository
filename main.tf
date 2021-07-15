resource "kubernetes_manifest" "this" {
  provider = kubernetes-alpha

  manifest = local.git_repository
}

resource "tls_private_key" "this" {
  count = local.create_ssh_key ? 1 : 0

  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "kubernetes_secret" "this" {
  count = local.create_ssh_key ? 1 : 0

  depends_on = [kubernetes_manifest.this]

  metadata {
    name      = local.secret_name
    namespace = local.namespace
  }

  data = {
    identity       = tls_private_key.this[0].private_key_pem
    "identity.pub" = tls_private_key.this[0].public_key_pem
    known_hosts    = local.known_hosts_string
  }
}
