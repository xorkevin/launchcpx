NAMESPACE=vault
KUBE_ARGS=-n $(NAMESPACE)
KUBECTL=kubectl $(KUBE_ARGS)

HELMCHART_REPO=https://github.com/hashicorp/vault-helm
HELMCHART_DIR=helmchart
HELM_ARGS=--namespace $(NAMESPACE)

KEYDIR=keys
KEYFILE=$(KEYDIR)/cluster.json
UNSEAL_KEY=$(shell jq -r '.unseal_keys_b64[]' $(KEYFILE))
ROOT_TOKEN=$(shell jq -r '.root_token' $(KEYFILE))

SA_NAME=vault
SA_SECRET=$(shell $(KUBECTL) get sa/$(SA_NAME) -o=json | jq -r '.secrets[].name')
SA_TOKEN=$(shell $(KUBECTL) get secrets/$(SA_SECRET) -o=json | jq -r '.data.token' | base64 -d)
SA_CRT_CMD=$(KUBECTL) get secrets/$(SA_SECRET) -o=json | jq -r '.data["ca.crt"]' | base64 -d
KUBE_HOST=kubernetes.default.svc.cluster.local

VAULTPOD=vault-0
KUBEEXEC=$(KUBECTL) exec -it $(VAULTPOD) --
KUBEVAULT=$(KUBEEXEC) vault
VAULT=VAULT_ADDR=http://vault.dev.localhost:8080/ vault

.PHONY: devinit devup devupdate devdown devclean

devinit:
	if [ ! -e $(HELMCHART_DIR) ]; then \
		git clone $(HELMCHART_REPO) $(HELMCHART_DIR); \
	fi
	kubectl apply -f ./namespace.yaml

devup:
	helm install $(HELM_ARGS) -f values.yaml vault ./helmchart

devup2:
	kubectl apply -k ./base

devupdate:
	helm upgrade $(HELM_ARGS) -f values.yaml vault ./helmchart

devdown:
	helm uninstall $(HELM_ARGS) vault

devclean:
	rm -rf $(KEYDIR)

.PHONY: opinit unseal seal roottoken login

opinit:
	mkdir -p $(KEYDIR)
	if [ ! -e $(KEYFILE) ]; then \
		$(KUBEVAULT) operator init -key-shares=1 -key-threshold=1 -format=json > $(KEYFILE); \
	fi

unseal:
	@$(KUBEVAULT) operator unseal $(UNSEAL_KEY)

seal:
	@$(KUBEVAULT) operator seal

roottoken:
	@echo $(ROOT_TOKEN)

login:
	@$(VAULT) login $(ROOT_TOKEN)

.PHONY: satoken sacrt

satoken:
	@echo $(SA_TOKEN)

sacrt:
	@$(SA_CRT_CMD)

.PHONY: enable-kube config-kube enable-db enable-all

enable-kube:
	$(VAULT) auth enable kubernetes

config-kube:
	@$(SA_CRT_CMD) | $(VAULT) write auth/kubernetes/config \
		token_reviewer_jwt="$(SA_TOKEN)" \
		kubernetes_host="https://$(KUBE_HOST):443" \
		kubernetes_ca_cert=-

enable-db:
	$(VAULT) secrets enable database

enable-kv:
	$(VAULT) secrets enable -version=2 kv

enable-all: enable-kube config-kube enable-db enable-kv
