#
# Package IP script
#
set proj_name $env(VIVADO_PROJ_NAME)

# Sources
set srcRoot [file normalize [pwd]/src]
set ipRoot [file normalize [pwd]/../../../ip]

# Outputs
set outputDir [file normalize [pwd]/run]
set productsDir [file normalize [pwd]/products]

# Project parameters
set_param general.maxThreads 32
set jobs [get_param general.maxThreads]

# List of source files
set hdl_list [glob $srcRoot/*]
puts "hdl_list-1: $hdl_list"

# List of library source files
if {[info exists ::env(DEP_LIST)]} {
    set lib_list $env(DEP_LIST)
}

# List of xdc constraints files
if {[info exists ::env(XDC_LIST)]} {
    set xdc_list $env(XDC_LIST)
}

# A little bit of magic to remove empty strings 
set hdl_list [list {*}$hdl_list {*}$lib_list ]
set hdl_list [lsearch -all -inline -not -exact $hdl_list {}]
puts "hdl_list-2: $hdl_list"
