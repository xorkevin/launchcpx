.PHONY: devinit devup devdown

devinit:
	kubectl apply -f ./namespace.yaml
	istioctl operator init

devup:
	kubectl apply -k ./base

devdown:
	kubectl delete -k ./base
