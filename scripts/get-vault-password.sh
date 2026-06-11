#!/usr/bin/env sh
# Retrieve the Ansible vault password.
# Order of precedence:
#   1. ANSIBLE_VAULT_PASSWORD environment variable
#   2. File at ~/.config/ansible/krugten-vault-password
set -e

if [ -n "${ANSIBLE_VAULT_PASSWORD:-}" ]; then
  printf '%s' "$ANSIBLE_VAULT_PASSWORD"
  exit 0
fi

FILE="${ANSIBLE_VAULT_PASSWORD_FILE:-$HOME/.config/ansible/krugten-vault-password}"
if [ -f "$FILE" ]; then
  cat "$FILE"
  exit 0
fi

echo "ERROR: No vault password found.
Set ANSIBLE_VAULT_PASSWORD env var or create ~/.config/ansible/krugten-vault-password" >&2
exit 1
