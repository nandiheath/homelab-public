PATH := $(CURDIR)/bin:$(PATH)
HOMELAB ?= ./bin/homelab

.PHONY: render validate validate-ansible validate-bootstrap validate-manifests

render:
	@if [ -n "$(SOURCE)" ]; then \
		test -n "$(OUTPUT)"; \
		$(HOMELAB) argocd render --path "$(SOURCE)" --output "$(OUTPUT)"; \
	else \
		$(HOMELAB) argocd render --all; \
	fi

validate: validate-ansible validate-bootstrap validate-manifests

validate-ansible:
	./scripts/validate-ansible.sh

validate-bootstrap:
	./tests/bootstrap/run.sh

validate-manifests:
	./scripts/validate.sh
