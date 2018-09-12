path "quorum/addresses/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/makers/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/validators/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/observers/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/keys/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/passwords/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/bootnodes/addresses/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/bootnodes/keys/*" {
  capabilities = ["read", "create", "update"]
}

path "quorum/bootnodes/passwords/*" {
  capabilities = ["read", "create", "update"]
}
