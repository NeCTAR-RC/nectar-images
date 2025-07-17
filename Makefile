# configuration
MAKEFLAGS      = --no-builtin-rules --silent --warn-undefined-variables
SHELL         := sh

.DEFAULT_GOAL := help
.ONESHELL     :
.SHELLFLAGS   := -eu -c


# configuration
color_off    = $(shell tput sgr0)
color_bright = $(shell tput bold)
color_red    = $(shell tput setaf 1)
color_green  = $(shell tput setaf 2)
color_yellow = $(shell tput setaf 3)
color_blue   = $(shell tput setaf 4)

# convenience function to alert user to missing target
define missing_target
	$(error Missing target. Specify with `target=<provider>`)
endef

.SILENT .PHONY: clear
clear:
	clear

.SILENT .PHONY: help
help: # Displays this help text
	$(info )
	$(info $(color_bright)PACKER TEMPLATES$(color_off))
	grep --context=0 --devices=skip --extended-regexp --no-filename "(^[a-z-]+):{1} ?(?:[a-z-])* #" $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1m%s\033[0m;%s\n", $$1, $$2}' | column -c2 -s ";" -t $(info )

.SILENT .PHONY: clean
clean:
	rm -frv builds/build_files/*

# convenience function to print version information when binary (temp variable $(1)) is available
define print_version_if_available
	echo "$(color_bright)$(color_green)==>$(color_off) $(color_bright)$(1)$(color_off): "$(if $(shell which $(1)),"$(shell $(1) $(2))", "not available")
endef

# convenience function to pretty-print version information when `ansible` binary is available
define print_ansible_version_if_available
	# expected output: `ansible 2.10.7`
	echo "$(color_bright)$(color_green)==>$(color_off) $(color_bright) ansible$(color_off): "$(if $(shell which ansible),"$(shell ansible --version | head -n 1)", "not available")
endef

# helper to print version information
.SILENT .PHONY: env-info
env-info: # Prints Version Information
	echo "Running environment:"
	# expected output: `1.7.8`
	$(call print_version_if_available, "packer", "--version")
	# expected output: `Vagrant 2.2.19`
	$(call print_version_if_available, "vagrant", "--version")
	$(call print_ansible_version_if_available)

# configuration for Packer-specific variables

# Debug mode enabled for builds.
debug ?=

ifdef debug
packer_debug = -debug
test_debug = -d
else
packer_debug =
test_debug =
endif

ifdef verbose
packer_verbose = $(verbose)
else
packer_verbose = 0
endif

# Build only the specified builds.
only ?=

ifdef only
packer_only = -only=$(only)
else
packer_only = -only=qemu.vm
endif

# If the build fails do: clean up (default), abort, ask, or run-cleanup-provisioner.
ifdef on-error
packer_on_error = -on-error=$(on-error)
else
packer_on_error = -on-error=cleanup
endif

# Enable prefixing of each ui output with an RFC3339 timestamp.
ifdef timestamp-ui
packer_timestamp_ui = -timestamp-ui
else
packer_timestamp_ui =
endif

ifdef headless
packer_headless = -var "headless=$(headless)"
else
packer_headless =
endif

ifdef test-build
packer_test_build = -var "test_build=$(test-build)"
else
packer_test_build =
endif

# expose build target to Packer
packer_var_target = $(target)

ifdef var-file
packer_var_file = -var-file=$(var-file)
else
packer_var_file =
endif

# see https://www.packer.io/docs/commands/build
.PHONY: build
build: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	rm -frv ./builds/build_files/packer-$(packer_var_target); \
	export PACKER_LOG=$(packer_verbose); \
	packer build $(packer_debug) \
			$(packer_on_error) \
			$(packer_timestamp_ui) \
			$(packer_headless) \
			$(packer_test_build) \
			$(packer_only) \
			$(packer_var_file) \
			-var-file="./vars/$(packer_var_target).pkrvars.hcl" \
			./packer

.PHONY: test
test: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	./scripts/run_image_tests.sh \
			$(test_debug) \
			-f ./builds/build_files/packer-$(packer_var_target)/image.qcow2

# see https://www.packer.io/docs/commands/init
.PHONY: init
init: # Installs and upgrades Packer Plugins
	# Download virtio-win ISO for Windows builds
	$(if $(target),,$(call missing_target))
ifneq (,$(findstring windows,$(packer_var_target)))
# Get a local writable copy of the UEFI OVMF VARS if it doesn't exist already
ifeq (,$(wildcard ./builds/build_files/efivars.fd))
	echo "Copying OVMF EFI vars file..."
	cp -v /usr/share/OVMF/OVMF_VARS_4M.fd ./builds/build_files/efivars.fd
	chmod 0644 ./builds/build_files/efivars.fd
endif
endif
# Download VirtIO Win ISO if it doesn't exist already
ifeq (,$(wildcard ./builds/build_files/virtio-win.iso))
	echo "Downloading virtio-win.iso..."
	curl -s -L -o ./builds/build_files/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
endif
	# Ensure mode 0600 for packer-ssh-key
	chmod 0600 ./packer/packer-ssh-key
	packer init -upgrade "./packer/"

# see https://www.packer.io/docs/commands/fmt
# and https://www.packer.io/docs/commands/validate
.PHONY: lint
lint: # Formats and validates Packer Template
	$(if $(target),,$(call missing_target))
	packer validate $(packer_only) \
			$(packer_var_file) \
			-var-file="./vars/$(packer_var_target).pkrvars.hcl" \
			./packer

.PHONY: vagrant-init
vagrant-init:
	export VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1; \
	vagrant plugin install vagrant-libvirt

.PHONY: vagrant-up
vagrant-up: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	vagrant up --no-destroy-on-error --provider=libvirt $(packer_var_target)

.PHONY: vagrant-down
vagrant-down: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	vagrant destroy -f $(packer_var_target)
