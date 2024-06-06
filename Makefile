OS_TYPE  = $(shell echo $(shell uname) | tr A-Z a-z)
OS_ARCH := amd64

TERRAFORM         := ./terraform
TERRAFORM_VERSION := 1.5.7
TERRAFORM_URL      = https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(OS_TYPE)_$(OS_ARCH).zip

EXCLUDES_DIRS := _test _example .terraform
MODULE_DIRS    = $(shell find . -type f -name "*.tf" | xargs -I {} dirname {} | grep -v $(foreach _d, $(EXCLUDES_DIRS), -e $(_d)) | uniq | sort)

.PHONY: help all deps clean validate $(MODULE_DIRS)
.DEFAULT_GOAL := help

help:
	@more Makefile

all: deps validate

deps: $(TERRAFORM)
	$(TERRAFORM) version

clean:
	@/bin/rm -f $(TERRAFORM)
	@$(foreach _d, $(MODULE_DIRS), find $(_d) -type f -name "fixture_*.tf" -delete;)

$(TERRAFORM):
	curl -L -fsS --retry 2 -o $@.zip $(TERRAFORM_URL)
	unzip $@.zip && rm -f $@.zip
	@chmod +x $@

$(MODULE_DIRS):
	/bin/cp -af _test/tf_fixtures/fixture_*.tf $@/
	$(TERRAFORM) -chdir=$@ init -input=false

validate: $(TERRAFORM) $(MODULE_DIRS)
	@echo "[Validate to terraform modules]"
	@for tf_dir in $(MODULE_DIRS); do \
	  printf "%-33s ... " "$$tf_dir"; \
	  $(TERRAFORM) -chdir=$$tf_dir $@ && echo "OK" || IF_ERROR=1; \
	done; exit $$IF_ERROR
