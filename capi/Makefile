
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

gha-clusterctl-install:
	curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.7.2/clusterctl-linux-amd64 -o clusterctl
	mkdir -p /tmp/bin
	install -m 0755 clusterctl /tmp/bin/clusterctl

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
	kubectl get secret --field-selector=type=helm.sh/release.v1 -o yaml > $(SAVE_DIR)/helm.yaml

clusterctl-restore:
	mkdir -p $(SAVE_DIR)
	clusterctl move --from-directory $(SAVE_DIR)
	[ -f $(SAVE_DIR)/helm.yaml ] && kubectl apply -f - < $(SAVE_DIR)/helm.yaml || echo "$(SAVE_DIR)/helm.yaml doesn't exist"

CLUSTERCTL_SAVE_BUCKET ?= changeme
OBJ_ACCESS_KEY ?= changeme
OBJ_SECRET_KEY ?= changeme
clusterctl-upload:
	s3cmd sync --config .s3cfg --access_key=$(OBJ_ACCESS_KEY) --secret_key=$(OBJ_SECRET_KEY) --delete-removed --force .clusterctl-save/ s3://$(CLUSTERCTL_SAVE_BUCKET)/.clusterctl-save/

clusterctl-download:
	s3cmd sync --config .s3cfg --access_key=$(OBJ_ACCESS_KEY) --secret_key=$(OBJ_SECRET_KEY) --delete-removed --force s3://$(CLUSTERCTL_SAVE_BUCKET)/.clusterctl-save/ .clusterctl-save/

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
