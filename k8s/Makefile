.PHONY: reclaimpv

reclaimpv:
	kubectl delete pv $$(kubectl get pv -o=json | jq -r '.items[] | select(.status.phase == "Released") | .metadata.name')
