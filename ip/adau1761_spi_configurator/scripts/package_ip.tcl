#
# STEP #0: define input and output directories, create project
#
set proj_name $env(VIVADO_PROJ_NAME)
set rev None

# Sources
set hdlRoot [file normalize [pwd]/hdl]
set xdcRoot [file normalize [pwd]/xdc]
set ipRoot [file normalize [pwd]/ip]
set bdRoot [file normalize [pwd]/bd]
set scriptsRoot [file normalize [pwd]/scripts]

# Outputs
set proj_dir [file normalize [pwd]/project]
set outputDir [file normalize [pwd]/run]
set productsDir [file normalize [pwd]/products]

# Project parameters
set_param general.maxThreads 8
set jobs [get_param general.maxThreads]

# User defined HDL list
set hdl_list {./src/adau1761_spi_configurator.v
}

create_project -force $proj_name -dir $outputDir

set_property TARGET_LANGUAGE VERILOG [current_project]

import_files -fileset sources_1 $hdl_list

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -taxonomy /UserIP -import_files -set_current false -force

# Define additional inferences as needed
ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1
set_property core_revision 1 [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
