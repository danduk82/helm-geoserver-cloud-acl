HELM ?= helm
LOCAL_IP ?= $(shell hostname -I | awk '{print $$1}')

.PHONY: examples-clean
examples-clean:
	rm -f examples/common/charts/*.tgz
	rm -f examples/datadir/charts/*.tgz
	${HELM} uninstall gs-cloud-common || /bin/true
	${HELM} uninstall gs-cloud-datadir || /bin/true

examples/common/charts/postgresql-12.1.6.tgz:
	${HELM} dependency update examples/common

.PHONY: dependencies
dependencies:
	${HELM} dependency update .

.PHONY: gen-expected
gen-expected: dependencies
	${HELM} dependency update examples/common
	${HELM} dependency update examples/datadir
	${HELM} template --namespace=default gs-cloud-common examples/common > tests/expected-common.yaml
	${HELM} template --namespace=default gs-cloud-datadir examples/datadir > tests/expected-datadir.yaml

.PHONY: example-common
example-common: examples/common/charts/postgresql-12.1.6.tgz
	${HELM} upgrade --install --set-json 'nfsserver="${LOCAL_IP}"' gs-cloud-common examples/common

.PHONY: example-datadir
example-datadir: example-common
	${HELM} dependency update examples/datadir
	${HELM} upgrade --install gs-cloud-datadir examples/datadir


