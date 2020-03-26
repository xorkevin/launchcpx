# Vault

## Dev

- `helm install -f pgvalues.yaml vaultpg bitnami/postgresql`
- `kubectl create secret generic vault-storage-config --from-file=config.hcl`
- [Helm chart](https://github.com/hashicorp/vault-helm)
- `git clone https://github.com/hashicorp/vault-helm helmchart`
- `git checkout v0.4.0`
- `helm install -f values.yaml vault ./helmchart`
- `helm list`
- `helm status vault`
- `helm upgrade -f values.yaml vault ./helmchart`
- `helm uninstall vault`
- `helm uninstall vaultpg`
