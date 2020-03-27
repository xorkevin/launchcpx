KEYDIR=keys
KEYFILE=$(KEYDIR)/cluster.json

ROOTTOKEN=$(shell jq -r '.root_token' $(KEYFILE))
VAULTPOD=vault-0
KUBEEXEC=kubectl exec -it $(VAULTPOD) --
KUBEVAULT=$(KUBEEXEC) vault
VAULT=VAULT_ADDR=http://127.0.0.1:8200/ vault

.PHONY: pgup pgdown

pgup:
	helm install -f pgvalues.yaml vaultpg bitnami/postgresql

pgdown:
	helm uninstall vaultpg

.PHONY: vinit vup vdown

vinit:
	kubectl create secret generic vault-storage-config --from-file=config.hcl

vup:
	helm install -f values.yaml vault ./helmchart

vdown:
	helm uninstall vault

.PHONY: devinit devup devdown devforward devclean

devinit: vinit

devup: pgup vup

devdown: vdown pgdown

devforward:
	kubectl port-forward svc/vault 8200:8200 >/dev/null 2>&1

devclean:
	rm -rf $(KEYDIR)

.PHONY: opinit unseal roottoken login enable-kube enable-db

opinit:
	@mkdir -p $(KEYDIR)
	@if [ ! -e $(KEYFILE) ]; then \
		 $(KUBEVAULT) operator init -key-shares=1 -key-threshold=1 -format=json > $(KEYFILE); \
	fi

unseal:
	@$(VAULT) operator unseal $$(jq -r '.unseal_keys_b64[]' $(KEYFILE))

roottoken:
	@echo $(ROOTTOKEN)

login:
	@$(VAULT) login $(ROOTTOKEN)

enable-kube:
	$(VAULT) auth enable kubernetes

enable-db:
	$(VAULT) secrets enable database
