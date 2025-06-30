include ../scripts/make_env.mk

# Vivado variables (user-defined)
export VIVADO_PROJ_NAME := fir_highpass
export VIVADO_VENDOR := niiichtsy
export VIVADO_LIBRARY := muleon

# Core version 
export VERSION := 1.0
export REVISION := 1

# Library dependecies
export DEP_LIST += 

# Constraint sources
export XDC_LIST += 

.PHONY: all clean ip

clean:
	@$(call print,Cleaning IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...)
	@$(RM) $(VIVADO_PROJ_NAME) $(VIV_PRJ_DIR) vivado* .Xil *dynamic* *.log *.xpe *.mif \
	$(RM) $(VIV_REPORTS_DIR) $(VIV_PROD_DIR) $(HIDE)

ip: $(VIV_PROD_DIR)

$(VIV_PROD_DIR): $(shell find $(VIV_SRC_DIR) $(DEP_LIST) $(XDC_LIST))
	@$(call print_nonl,Building IP $(call yellow,$(VIVADO_PROJ_NAME)) for Git SHA commit $(call green,$(GIT_SHA))...); 
	@$(VIV_RUN) -mode batch -notrace -source $(VIV_IP) $(HIDE);
	@$(call print_nots, $(call green,OK));
