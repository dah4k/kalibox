# Copyright 2024 dah4k
# SPDX-License-Identifier: EPL-2.0

HASHICORP_REPO_URL   := https://rpm.releases.hashicorp.com/RHEL/9/$$basearch/stable
HASHICORP_REPO_NAME  := "Hashicorp Stable - RHEL 9 - $$basearch"
HASHICORP_REPO_ALIAS := hashicorp
HASHICORP_RPM_GPG    := https://rpm.releases.hashicorp.com/gpg
HOST_REQUIREMENTS    := virtualbox vagrant

_ANSI_NORM  := \033[0m
_ANSI_CYAN  := \033[36m

help usage:
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?##"}; {printf "$(_ANSI_CYAN)%-20s$(_ANSI_NORM) %s\n", $$1, $$2}'

start: ## Start all VMs (vagrant up)
	vagrant up

stop: ## Stop all VMs (vagrant halt)
	vagrant halt

test: ## Run unit tests
	ruby tests/*

distclean: ## Destroy all VMs (vagrant destroy --force)
	vagrant destroy --force

install_requirements: ## Install host requirements
	zypper repos $(HASHICORP_REPO_ALIAS) || (sudo zypper addrepo --refresh --gpgcheck --name $(HASHICORP_REPO_NAME) $(HASHICORP_REPO_URL) $(HASHICORP_REPO_ALIAS) && sudo rpm --import $(HASHICORP_RPM_GPG))
	sudo zypper install $(HOST_REQUIREMENTS)

.PHONY: help usage start stop test distclean install_requirements
