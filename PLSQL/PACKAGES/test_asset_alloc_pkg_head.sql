create or replace package test_asset_allocation_pkg
as
    create or replace function f_build_asset_allocation_obj
    return asset_alloc_tab;

    create or replace procedure p_test_asset_allocation;
end test_asset_allocation_pkg;
/