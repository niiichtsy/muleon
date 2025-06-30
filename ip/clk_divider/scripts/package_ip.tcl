source ../scripts/tcl_env.tcl
source scripts/core_info.tcl

create_project -force $proj_name -dir $outputDir

set_property TARGET_LANGUAGE VERILOG [current_project]
set_property  ip_repo_paths  "$productsDir/" [current_project]
update_ip_catalog

add_files -fileset sources_1 $hdl_list

if {[info exists xdc_list]} {
    if {$xdc_list != ""} {
        add_files -fileset constrs_1 $xdc_list
    }
}

ipx::package_project -root_dir $productsDir -vendor $env(VIVADO_VENDOR) -library $env(VIVADO_LIBRARY) -import_files -taxonomy /UserIP -set_current false -force
ipx::unload_core $productsDir/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $productsDir $productsDir/component.xml
update_compile_order -fileset sources_1

set cc [ipx::current_core]
set_property version $info_ipCoreVersion $cc
set_property core_revision $info_ipCoreRevision $cc
set_property display_name $info_ipCoreDisplayName $cc
set_property description $info_ipCoreDescription $cc

# Define additional inferences as needed
ipx::infer_bus_interface clk_in xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface clk_out xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

ipx::update_source_project_archive -component $cc
ipx::create_xgui_files $cc
ipx::update_checksums $cc
ipx::check_integrity $cc
ipx::save_core $cc
ipx::move_temp_component_back -component $cc
close_project -delete
