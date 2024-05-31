
CAPL_VERSION ?= "v0.3.0"

check-env:
	@if [ -z "$(LINODE_TOKEN)" ] ; then \
		echo "LINODE_TOKEN is not set"; exit 1; \
	fi;

kind-create:
	kind create cluster --name afn-capi

kind-clean:
	kind delete cluster --name afn-capi

clusterctl-init: check-env
	mkdir -p ~/.cluster-api
	cp clusterctl.yaml ~/.cluster-api/
	clusterctl init --bootstrap k3s --control-plane k3s --infrastructure linode-linode:$(CAPL_VERSION) --addon helm

clusterctl-save:
	mkdir -p .clusterctl-save/
	clusterctl move --to-directory .clusterctl-save/

AFN_CAPL_VALUES_FILE ?= "afn-capl/values.yaml"
AFN_CAPL_RELEASE ?= "example"
helm-install-afn-capl: check-env
	helm upgrade --install --values $(AFN_CAPL_VALUES_FILE) --set linodeApiToken=$(LINODE_TOKEN) $(AFN_CAPL_RELEASE) afn-capl/

helm-uninstall-afn-capl:
	helm uninstall $(AFN_CAPL_RELEASE) 
