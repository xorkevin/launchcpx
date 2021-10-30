.PHONY: devinit devup devdown

devinit:
	kubectl apply -f ./namespace.yaml
	istioctl operator init

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base

.PHONY: gateup gatedown

gateup:
	kubectl apply -k ./gate

gatedown:
	kubectl delete -k ./gate

.PHONY: ports devforward

INGRESS_HOST=$(shell minikube ip)
INGRESS_PORT=$(shell kubectl -n istio-system get service istio-ingressgateway -o=json | jq -r '.spec.ports[] | select(.name == "http2") | .nodePort')
INGRESS_PORT_TLS=$(shell kubectl -n istio-system get service istio-ingressgateway -o=json | jq -r '.spec.ports[] | select(.name == "https") | .nodePort')

ports:
	@echo 'host:' $(INGRESS_HOST)
	@echo 'port:' $(INGRESS_PORT)
	@echo 'tlsport:' $(INGRESS_PORT_TLS)

SRC_PORT=8080

devforward:
	interchange fwd -t $(SRC_PORT):$(INGRESS_HOST):$(INGRESS_PORT)
