include vars.mk
include ../../make/pkg/base/base.mk
include ../../make/pkg/string/string.mk
include ../../make/pkg/color/color.mk
include ../../make/pkg/functions/functions.mk
include ../../make/targets/buildenv/buildenv.mk
include ../../make/targets/git/git.mk

PROJECT_TARGETS:=$(PROJECT_NAME)
ifneq ($(CONTAINER_COUNT),)
CONTAINER_SEQ:=$(shell seq $(CONTAINER_COUNT))
PROJECT_TARGETS = $(CONTAINER_SEQ:%=$(PROJECT_NAME)-%)
endif

PROJECT_CONTAINERS=$(PROJECT_TARGETS:%=lxd-%)
LXD_TARGETS = $(PROJECT_CONTAINERS)
LXD_START_TARGETS = $(PROJECT_TARGETS:%=lxd-start-%)
LXD_STOP_TARGETS = $(PROJECT_TARGETS:%=lxd-stop-%)
LXD_CLEAN_TARGETS = $(PROJECT_TARGETS:%=lxd-clean-%)

include ../../make/targets/lxd/lxd.mk

THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
TAGS:=$(shell cat site.yml | yq '.[].roles[]?.tags[]?')
.PHONY: $(PROJECT_NAME)
.SILENT: $(PROJECT_NAME)
$(PROJECT_NAME): $(PROJECT_NAME)-inventories
	- $(call print_running_target)
	- $(call print_running_target)
	- $(eval command=ansible-playbook -i staging site.yml --limit staging)
ifneq ($(VAULT_PASSWORD_FILE),)
	- $(eval command=$(command) --vault-password-file $(VAULT_PASSWORD_FILE))
	- $(eval command=$(command) -e vault_password_file=$(VAULT_PASSWORD_FILE))
endif
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)

.PHONY: $(PROJECT_NAME)-inventories
.SILENT: $(PROJECT_NAME)-inventories
$(PROJECT_NAME)-inventories:
	- $(call print_running_target)
	- echo '[lxc]' | tee $(SELF_DIR)/staging > /dev/null
	- seq $(CONTAINER_COUNT) | xargs -I {} echo "$(PROJECT_NAME)-{}" | tee -a $(SELF_DIR)/staging > /dev/null
	- echo '[staging:children]' | tee -a $(SELF_DIR)/staging > /dev/null
	- echo 'lxc' | tee -a $(SELF_DIR)/staging > /dev/null
	- $(call print_completed_target)
.PHONY: $(PROJECT_NAME)-containers
.SILENT: $(PROJECT_NAME)-containers
$(PROJECT_NAME)-containers:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_TARGETS)
	- $(call print_completed_target)
.PHONY: $(PROJECT_NAME)-clean
.SILENT: $(PROJECT_NAME)-clean
$(PROJECT_NAME)-clean:
	- $(call print_running_target)
	- @$(MAKE) --no-print-directory -f $(THIS_FILE) $(LXD_CLEAN_TARGETS)
	- $(call print_completed_target)
.PHONY:info
.SILENT: info
info:
	- $(info $(TAGS))

.PHONY:$(TAGS)
.SILENT:$(TAGS)
$(TAGS):
	- $(call print_running_target)
	- $(call print_completed_target)
