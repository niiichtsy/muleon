# Useful hacks
red = \\e[31m$1\\e[39m
green = \\e[32m$1\\e[39m
yellow = \\e[33m$1\\e[39m
cyan = \\e[36m$1\\e[39m

# Helper print functions: regular, no newline and no timestamp
print = printf "$(call green,[$(TIMESTAMP)]) $1\n"
print_nonl = printf "$(call green,[$(TIMESTAMP)]) $1"
print_nots = printf "$1\n"

# Aliases & useful env variables
export DATESTAMP := $(shell date +"%H%d%m%g")
TIMESTAMP = $(shell date +"%T")
HIDE = >/dev/null
2HIDE = &>/dev/null
MUTE = @
RM = rm -rf
export SELF_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Git variables
export GIT_SHA = $(shell git rev-parse --short HEAD)
export GIT_BRANCH = $(shell git symbolic-ref --short HEAD)

# Vivado variables
VIV_RUN = $(XILINX_VIVADO)/bin/vivado
export VIV_SCRIPTS_DIR = scripts
export VIV_PRJ_DIR = run
export VIV_PROD_DIR = products
export VIV_SRC_DIR = src
VIV_IP = $(VIV_SCRIPTS_DIR)/package_ip.tcl
export PART := 

# IP Library path
IP_LIB_PATH := $(ROOT_DIR)/ip/

# IP List
IP_LIST += adau1761_spi_configurator 
IP_LIST += clk_divider
IP_LIST += delay
IP_LIST += distortion
IP_LIST += fir_highpass
IP_LIST += fir_lowpass

# Description
.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make ip'
	@echo '    Create and package Vivado IP'
	@echo '  make clean'
	@echo '    Clean Vivado projects files & output products produced in a previous run'
	@echo '  make lib'
	@echo '    Create and package IP library'
	@echo '  make clean-lib'
	@echo '    Clean Vivado projects files & output products for IP library'
	@echo ''

.PHONY: all lib clean-lib 

lib:
	@$(call print,Building $(call cyan, IP library) for Git SHA commit $(call green,$(GIT_SHA))...); \
	for lib in $(IP_LIST); do \
		$(MAKE) -C $(IP_LIB_PATH)$${lib} ip || exit $$?; \
	done 

clean-lib:

	@$(call print,Cleaning $(call cyan,IP library) for Git SHA commit $(call green,$(GIT_SHA))...); \
	for lib in $(IP_LIST); do \
		$(MAKE) -C $(IP_LIB_PATH)$${lib} clean || exit $$?; \
	done 
