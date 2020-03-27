.PHONY: devup devdown devforward devclean

devup:
	minikube start

devdown:
	minikube stop

devforward:
	minikube dashboard >/dev/null 2>&1

devclean:
	minikube delete
