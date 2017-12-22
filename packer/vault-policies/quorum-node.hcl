path "quorum/addresses/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/makers/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/validators/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/keys/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/passwords/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/bootnodes/*" {
  capabilities = ["read", "create", "update"]
}
