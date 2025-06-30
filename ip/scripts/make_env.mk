# Colors
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
RM = rm -rf
HIDE = >/dev/null
2HIDE = &>/dev/null

# Gitlab variables
GIT_SHA = $(shell git rev-parse --short HEAD)
GIT_BRANCH = $(shell git symbolic-ref --short HEAD)
export CI_COMMIT_SHORT_SHA := $(GIT_SHA)
export BIT_USERID := $(CI_COMMIT_SHORT_SHA)

# Xilinx tool variables
VIV_RUN = $(XILINX_VIVADO)/bin/vivado
export VIV_SCRIPTS_DIR = scripts
export VIV_PRJ_DIR = run
export VIV_PROD_DIR = products
export VIV_SRC_DIR = src
VIV_IP = $(VIV_SCRIPTS_DIR)/package_ip.tcl
export PART := xc7z020clg400-1
