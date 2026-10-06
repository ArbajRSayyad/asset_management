create or replace package test_asset_allocation_pkg
as
    function f_build_asset_allocation_obj
    return asset_alloc_tab;

    procedure p_test_asset_allocation;
end test_asset_allocation_pkg;
/