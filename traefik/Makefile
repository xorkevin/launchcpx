.PHONY: devup devdown

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base

.PHONY: ports devforward

INGRESS_HOST=$(shell minikube ip)
INGRESS_PORT=$(shell kubectl -n traefik-system get service traefik -o=json | jq -r '.spec.ports[] | select(.name == "web") | .nodePort')

ports:
	@echo 'host:' $(INGRESS_HOST)
	@echo 'port:' $(INGRESS_PORT)

SRC_PORT=8080

devforward:
	interchange fwd -t $(SRC_PORT):$(INGRESS_HOST):$(INGRESS_PORT)
