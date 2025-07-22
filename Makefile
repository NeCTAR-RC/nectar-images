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

# convenience function for a missing vars file
define missing_target_vars
	$(error Packer target not found. Ensure vars file exists.)
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
ifdef target
packer_var_target = $(target)
packer_target_file = ./vars/$(target).pkrvars.hcl
else
packer_var_target =
packer_target_file =
windows_iso_file =
endif

ifdef var-file
packer_var_file = -var-file=$(var-file)
else
packer_var_file =
endif

# Set Windows ISO filename variable
ifneq ($(findstring windows,$(packer_var_target)),)
$(if $(target),,$(call missing_target))
$(if $(wildcard $(packer_target_file)),,$(call missing_target_vars))
# Get filename part only from iso_url field of the vars file
windows_iso_file := $(shell sed -n 's|.*iso_url.*=\s*".*/\([^"/]*\)".*|\1|p' $(packer_target_file))
endif

# see https://www.packer.io/docs/commands/build
.PHONY: build
build: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	$(if $(wildcard $(packer_target_file)),,$(call missing_target_vars))
	rm -frv ./builds/build_files/packer-$(packer_var_target); \
	export PACKER_LOG=$(packer_verbose); \
	packer build $(packer_debug) \
			$(packer_on_error) \
			$(packer_timestamp_ui) \
			$(packer_headless) \
			$(packer_test_build) \
			$(packer_only) \
			$(packer_var_file) \
			-var-file=$(packer_target_file) \
			./packer

.PHONY: test
test: # Builds an Image with Packer
	$(if $(target),,$(call missing_target))
	./scripts/run_image_tests.sh \
			$(test_debug) \
			-f ./builds/build_files/packer-$(packer_var_target)/image.qcow2

# see https://www.packer.io/docs/commands/init
.PHONY: init
init:                  # Installs and upgrades Packer Plugins
	$(if $(packer_var_target),,$(call missing_target))
	$(if $(wildcard $(packer_target_file)),,$(call missing_target_vars))

ifneq ($(findstring windows,$(packer_var_target)),)
	# Get a local writable copy of the UEFI OVMF VARS if it doesn't exist already
	if [ ! -f ./builds/build_files/$(packer_var_target)-efivars.fd ]; then \
	  echo "Copying OVMF EFI vars file..."; \
	  cp /usr/share/OVMF/OVMF_VARS_4M.fd ./builds/build_files/$(packer_var_target)-efivars.fd; \
	  chmod 0644 ./builds/build_files/$(packer_var_target)-efivars.fd; \
	fi
	# Download Windows ISO if it doesn't exist already
	if [ ! -f ./builds/build_files/$(windows_iso_file) ]; then \
	  echo "Downloading Windows ISO $(windows_iso_file)..."; \
	  openstack object save iso $(windows_iso_file) \
	    --file ./builds/build_files/$(windows_iso_file); \
	fi
	# Download VirtIO Win ISO if it doesn't exist already
	if [ ! -f ./builds/build_files/virtio-win.iso ]; then \
	  echo "Downloading VirtIO Win ISO..."; \
	  openstack object save iso virtio-win-0.1.271.iso \
	    --file ./builds/build_files/virtio-win.iso; \
	fi
endif
	# Ensure mode 0600 for packer-ssh-key
	chmod 0600 ./packer/packer-ssh-key
	packer init -upgrade "./packer/"

# see https://www.packer.io/docs/commands/fmt
# and https://www.packer.io/docs/commands/validate
.PHONY: lint
lint: # Formats and validates Packer Template
	$(if $(target),,$(call missing_target))
	$(if $(wildcard $(packer_target_file)),,$(call missing_target_vars))
	packer validate $(packer_only) \
			$(packer_var_file) \
			-var-file=$(packer_target_file) \
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
