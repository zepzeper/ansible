.PHONY: help setup lint syntax-check \
        deploy bootstrap k3s manifests base apps \
        backup backup-run \
        tag ping facts clean

ANSIBLE_ARGS ?=

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Install control node dependencies
	pip3 install -r requirements.txt
	ansible-galaxy collection install -r requirements.yml

lint: ## Run ansible-lint on all playbooks and roles
	ansible-lint

syntax-check: ## Check playbook syntax
	ansible-playbook playbooks/deploy-all.yml --syntax-check
	ansible-playbook playbooks/bootstrap.yml --syntax-check
	ansible-playbook playbooks/k3s.yml --syntax-check
	ansible-playbook playbooks/k3s-manifests.yml --syntax-check
	ansible-playbook playbooks/backup.yml --syntax-check

deploy: ## Full deployment sequence (bootstrap → k3s → manifests)
	ansible-playbook playbooks/deploy-all.yml $(ANSIBLE_ARGS)

bootstrap: ## Bootstrap servers only (common + server roles)
	ansible-playbook playbooks/bootstrap.yml $(ANSIBLE_ARGS)

k3s: ## Install/update K3s and Tailscale
	ansible-playbook playbooks/k3s.yml $(ANSIBLE_ARGS)

base: ## Deploy Kubernetes infrastructure (cert-manager, nginx, MetalLB, etc.)
	ansible-playbook playbooks/k3s-manifests.yml --tags k8s-base $(ANSIBLE_ARGS)

apps: ## Deploy Kubernetes applications
	ansible-playbook playbooks/k3s-manifests.yml --tags k8s-apps $(ANSIBLE_ARGS)

manifests: ## Deploy all Kubernetes manifests (base + apps)
	ansible-playbook playbooks/k3s-manifests.yml $(ANSIBLE_ARGS)

backup: ## Install and configure backup system
	ansible-playbook playbooks/backup.yml $(ANSIBLE_ARGS)

backup-run: ## Trigger an immediate backup on all hosts
	ansible all -b -m systemd -a "name=restic-backup.service state=started"

tag: ## Run with specific tag: make tag TAG=firewall
	ansible-playbook playbooks/deploy-all.yml --tags "$(TAG)" $(ANSIBLE_ARGS)

ping: ## Ping all hosts
	ansible all -m ping

facts: ## Gather and cache facts from all hosts
	ansible all -m setup --tree /tmp/ansible-cache

clean: ## Clean cached facts and retry files
	rm -rf /tmp/ansible-cache *.retry
