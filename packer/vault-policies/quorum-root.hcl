path "quorum/addresses/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/makers/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/validators/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/observers/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/keys/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/passwords/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/bootnodes/addresses/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/bootnodes/keys/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/bootnodes/passwords/*" {
  capabilities = ["read", "create", "update", "delete"]
}

path "quorum/graveyard/*" {
  capabilities = ["read", "create"]
}
