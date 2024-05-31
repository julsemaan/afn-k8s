
CAPL_VERSION ?= v0.3.0
KIND_CLUSTER_NAME ?= afn-capi

check-env:
	@if [ -z "$(LINODE_TOKEN)" ] ; then \
		echo "LINODE_TOKEN is not set"; exit 1; \
	fi;

kind-create:
	kind get clusters | grep '^$(KIND_CLUSTER_NAME)' || kind create cluster --name $(KIND_CLUSTER_NAME)

kind-clean:
	kind delete cluster --name $(KIND_CLUSTER_NAME)

clusterctl-init: check-env kind-create
	mkdir -p ~/.cluster-api
	cp clusterctl.yaml ~/.cluster-api/
	clusterctl init --bootstrap k3s --control-plane k3s --infrastructure linode-linode:$(CAPL_VERSION) --addon helm
	while ! kubectl logs test-capl-webhook | grep 'capl-webhook-service.capl-system.svc.*open'; do\
		kubectl delete pod test-capl-webhook ; kubectl run --image=busybox test-capl-webhook -- nc -zv capl-webhook-service.capl-system.svc 443 ;\
		sleep 5 ;\
	done

SAVE_DIR ?= .clusterctl-save
clusterctl-save:
	rm -fr $(SAVE_DIR)
	mkdir -p $(SAVE_DIR)/
	clusterctl move --to-directory $(SAVE_DIR)

clusterctl-restore:
	clusterctl move --from-directory $(SAVE_DIR)

clusterctl-wait:
	while [ `kubectl get clusters -o yaml | yq '.items[] | select(.status.phase!="Provisioned")' | wc -l` -ne 0 ]; do \
		echo "Waiting on clusters" ;\
		kubectl get clusters ;\
		sleep 1;\
	done

	sleep 10

	while [ `kubectl get machines -o yaml | yq '.items[] | select(.status.phase!="Running")' | wc -l` -ne 0 ]; do \
		echo "Waiting on machines" ;\
		kubectl get machines ;\
		sleep 1;\
	done
	
AFN_CAPL_VALUES_FILE ?= afn-capl/values.yaml
AFN_CAPL_RELEASE ?= example
helm-install-afn-capl: check-env
	helm upgrade --install --values $(AFN_CAPL_VALUES_FILE) --set linodeApiToken=$(LINODE_TOKEN) $(AFN_CAPL_RELEASE) afn-capl/

helm-uninstall-afn-capl:
	helm uninstall $(AFN_CAPL_RELEASE) 
