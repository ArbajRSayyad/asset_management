create or replace procedure p_test_asset_allocation()
language plpgsql
as
$$
declare
    l_asset_alloc_tab asset_alloc_tab[];
begin

      select array_agg(alloc)
      into l_asset_alloc_tab
      from f_build_asset_allocation_obj() alloc;

      call p_process_asset_allocation(l_asset_alloc_tab);
end;
$$;
