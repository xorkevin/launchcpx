.PHONY: pgup pgdown

pgup:
	helm install -f pgvalues.yaml vaultpg bitnami/postgresql

pgdown:
	helm uninstall vaultpg

KEYDIR=keys
KEYFILE=$(KEYDIR)/cluster.json

.PHONY: vinit vup unseal vdown

vinit:
	kubectl create secret generic vault-storage-config --from-file=config.hcl

vup:
	helm install -f values.yaml vault ./helmchart

unseal:
	mkdir -p $(KEYDIR)
	if [ ! -e $(KEYFILE) ]; then \
		kubectl exec -it vault-0 -- \
			vault operator init -key-shares=1 -key-threshold=1 -format=json > $(KEYFILE); \
	fi
	kubectl exec -it vault-0 -- vault operator unseal $$(jq -r '.unseal_keys_b64[]' $(KEYFILE))

vdown:
	helm uninstall vault

.PHONY: devinit devup devstart devdown

devinit: vinit

devup: pgup vup

devstart: unseal

devdown: vdown pgdown
