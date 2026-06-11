.PHONY: help setup lint syntax-check \
        deploy bootstrap k3s manifests base apps \
        backup backup-run \
        tag ping facts clean

ANSIBLE_PLAYBOOK ?= ~/ansible-env/bin/ansible-playbook
ANSIBLE ?= ~/ansible-env/bin/ansible
ANSIBLE_GALAXY ?= ~/ansible-env/bin/ansible-galaxy
ANSIBLE_LINT ?= ~/ansible-env/bin/ansible-lint
ANSIBLE_ARGS ?=
LIMIT ?=

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install control node dependencies
	pip3 install -r requirements.txt
	$(ANSIBLE_GALAXY) collection install -r requirements.yml

lint: ## Run ansible-lint on all playbooks and roles
	$(ANSIBLE_LINT)

syntax-check: ## Check playbook syntax
	$(ANSIBLE_PLAYBOOK) playbooks/deploy-all.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) playbooks/k3s.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) playbooks/k3s-manifests.yml --syntax-check
	$(ANSIBLE_PLAYBOOK) playbooks/backup.yml --syntax-check

deploy: ## Full deployment sequence (bootstrap → k3s → manifests)
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/deploy-all.yml $(ANSIBLE_ARGS)

bootstrap: ## Bootstrap servers only (common + server roles)
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/bootstrap.yml $(ANSIBLE_ARGS)

k3s: ## Install/update K3s and Tailscale
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/k3s.yml $(ANSIBLE_ARGS)

base: ## Deploy Kubernetes infrastructure (cert-manager, nginx, MetalLB, etc.)
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/k3s-manifests.yml --tags k8s-base $(ANSIBLE_ARGS)

apps: ## Deploy Kubernetes applications
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/k3s-manifests.yml --tags k8s-apps $(ANSIBLE_ARGS)

manifests: ## Deploy all Kubernetes manifests (base + apps)
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/k3s-manifests.yml $(ANSIBLE_ARGS)

backup: ## Install and configure backup system
	$(ANSIBLE_PLAYBOOK) $(if $(LIMIT),--limit $(LIMIT)) playbooks/backup.yml $(ANSIBLE_ARGS)

backup-run: ## Trigger an immediate backup on all hosts
	$(ANSIBLE) all -b -m systemd -a "name=restic-backup.service state=started"

tag: ## Run with specific tag: make tag TAG=firewall
	$(ANSIBLE_PLAYBOOK) playbooks/deploy-all.yml --tags "$(TAG)" $(ANSIBLE_ARGS)

ping: ## Ping all hosts
	$(ANSIBLE) all -m ping

facts: ## Gather and cache facts from all hosts
	$(ANSIBLE) all -m setup --tree /tmp/ansible-cache

clean: ## Clean cached facts and retry files
	rm -rf /tmp/ansible-cache *.retry
