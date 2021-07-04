include vars.mk
include ../../contrib/make/pkg/base/base.mk
include ../../contrib/make/pkg/string/string.mk
include ../../contrib/make/pkg/color/color.mk
include ../../contrib/make/pkg/functions/functions.mk
include ../../contrib/make/targets/buildenv/buildenv.mk
include ../../contrib/make/targets/git/git.mk
THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
.PHONY: clean
.SILENT: clean
clean:
	- $(call print_running_target)
	- terraform destroy -auto-approve || true
	- find . \
		-name 'terraform.tfstate*' \
		-o -name '.terraform*' \
		-o -name 'dev.log' \
		| xargs --no-run-if-empty -I {} -P `nproc` rm -r {}
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
.PHONY: minikube
.SILENT: minikube
minikube:
	- $(call print_running_target)
	- minikube start || true
	- timeout 120 minikube addons enable ingress || true
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)

.PHONY: $(PROJECT_NAME)
.SILENT: $(PROJECT_NAME)
$(PROJECT_NAME): minikube clean
	- $(call print_running_target)
	- $(eval command=bash demo.sh)
	- @$(MAKE) --no-print-directory \
	 -f $(THIS_FILE) shell cmd="${command}"
ifneq ($(DELAY),)
	- sleep $(DELAY)
endif
	- $(call print_completed_target)
