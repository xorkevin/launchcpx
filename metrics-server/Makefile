NAMESPACE=kube-system
KUBE_ARGS=-n $(NAMESPACE)
KUBECTL=kubectl $(KUBE_ARGS)

.PHONY: devup devdown

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base
