.PHONY: devinit devup devdown

devinit:
	kubectl apply -f ./namespace.yaml

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base
