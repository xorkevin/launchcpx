.PHONY: reclaimpv

reclaimpv:
	kubectl delete $$(kubectl get pv -o=json | jq -r '.items[] | select(.status.phase == "Released") | .metadata.name')
