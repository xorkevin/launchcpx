NAMESPACE=prometheus-system
KUBE_ARGS=-n $(NAMESPACE)
KUBECTL=kubectl $(KUBE_ARGS)

.PHONY: devup devdown

devup:
	kubectl apply -k .

devdown:
	kubectl delete -k .

.PHONY: devforward

devforward:
	$(KUBECTL) port-forward svc/prometheus 9090:9090 >/dev/null 2>&1
