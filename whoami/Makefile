NAMESPACE=whoami

.PHONY: devinit devup devdown

devinit:
	if [ -z $$(kubectl get ns -o=name | grep 'namespace/$(NAMESPACE)') ]; then \
		kubectl create namespace $(NAMESPACE); \
	fi

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base
