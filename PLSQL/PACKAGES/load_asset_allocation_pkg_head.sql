create or replace package load_asset_allocation_pkg
as
  procedure p_process_asset_allocation(pi_asset_alloc_tab asset_alloc_tab);
end load_asset_allocation_pkg;
/