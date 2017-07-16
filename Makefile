OS_TYPE  = $(shell echo $(shell uname) | tr A-Z a-z)
OS_ARCH := amd64

TERRAFORM         := ./terraform
TERRAFORM_VERSION := 0.9.11
TERRAFORM_URL      = https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(OS_TYPE)_$(OS_ARCH).zip

.PHONY: help all deps validate
.DEFAULT_GOAL := help

help:
	@more Makefile

all: deps validate

deps: $(TERRAFORM)
	@$< version

$(TERRAFORM):
	curl -L -fsS --retry 2 -o $@.zip $(TERRAFORM_URL)
	unzip $@.zip && rm -f $@.zip

validate: $(TERRAFORM)
	@echo "[Validate on terraform modules]"
	@for tf_dir in $$(find . -type f -name "*.tf" | xargs -I {} dirname {} | uniq | sort); do \
	  printf "%-30s ... " "$$tf_dir"; \
	  $(TERRAFORM) $(@F) $$tf_dir && echo "OK" || IF_ERROR=1; \
	done; exit $$IF_ERROR
