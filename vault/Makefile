HELMCHART=https://github.com/hashicorp/vault-helm

KEYDIR=keys
KEYFILE=$(KEYDIR)/cluster.json
UNSEAL_KEY=$(shell jq -r '.unseal_keys_b64[]' $(KEYFILE))
ROOT_TOKEN=$(shell jq -r '.root_token' $(KEYFILE))

VAULTPOD=vault-0
KUBEEXEC=kubectl exec -it $(VAULTPOD) --
KUBEVAULT=$(KUBEEXEC) vault
VAULT=VAULT_ADDR=http://127.0.0.1:8200/ vault

.PHONY: devinit devup devdown devforward devclean

devinit:
	git clone $(HELMCHART) helmchart

devup:
	helm install -f values.yaml vault ./helmchart

devdown:
	helm uninstall vault

devforward:
	kubectl port-forward svc/vault 8200:8200 >/dev/null 2>&1

devclean:
	rm -rf $(KEYDIR)

.PHONY: opinit unseal roottoken login enable-kube enable-db

opinit:
	mkdir -p $(KEYDIR)
	if [ ! -e $(KEYFILE) ]; then \
		 $(KUBEVAULT) operator init -key-shares=1 -key-threshold=1 -format=json > $(KEYFILE); \
	fi

unseal:
	@$(KUBEVAULT) operator unseal $(UNSEAL_KEY)

roottoken:
	@echo $(ROOT_TOKEN)

login:
	@$(VAULT) login $(ROOT_TOKEN)

enable-kube:
	$(VAULT) auth enable kubernetes

enable-db:
	$(VAULT) secrets enable database
