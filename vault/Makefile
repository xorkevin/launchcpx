HELMCHART=https://github.com/hashicorp/vault-helm

KEYDIR=keys
KEYFILE=$(KEYDIR)/cluster.json
UNSEAL_KEY=$(shell jq -r '.unseal_keys_b64[]' $(KEYFILE))
ROOT_TOKEN=$(shell jq -r '.root_token' $(KEYFILE))

SA_NAME=vault
SA_SECRET=$(shell kubectl get sa/$(SA_NAME) -o=json | jq -r '.secrets[].name')
SA_TOKEN=$(shell kubectl get secrets/$(SA_SECRET) -o=json | jq -r '.data.token' | base64 -d)
SA_CRT=$(shell kubectl get secrets/$(SA_SECRET) -o=json | jq -r '.data["ca.crt"]' | base64 -d)
KUBE_HOST=$(shell kubectl get svc/kubernetes -o=json | jq -r '.spec.clusterIP')

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

.PHONY: opinit unseal roottoken login

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

.PHONY: satoken sacrt kubehost

satoken:
	@echo $(SA_TOKEN)

sacrt:
	@echo $(SA_CRT)

kubehost:
	@echo $(KUBE_HOST)

.PHONY: enable-kube config-kube enable-db

enable-kube:
	$(VAULT) auth enable kubernetes

config-kube:
	@$(VAULT) write auth/kubernetes/config \
		token_reviewer_jwt="$(SA_TOKEN)" \
		kubernetes_host="https://$(KUBE_HOST):443" \
		kubernetes_ca_cert="$(SA_CRT)"

enable-db:
	$(VAULT) secrets enable database
