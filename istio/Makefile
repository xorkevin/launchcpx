NAMESPACE=istio-system

.PHONY: devinit devup devdown

devinit:
	if [ -z $$(kubectl get ns -o=name | grep 'namespace/$(NAMESPACE)') ]; then \
		kubectl create namespace $(NAMESPACE); \
	fi
	istioctl operator init

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base
