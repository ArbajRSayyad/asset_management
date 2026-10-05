create or replace package body test_asset_allocation_pkg
as
    create or replace function f_build_asset_allocation_obj
    return asset_alloc_tab
    as
        l_asset_tab asset_tab := asset_tab();
        l_asset_alloc_tab asset_alloc_tab := asset_alloc_tab();
     begin
        select asset_obj(asset_id)
        bulk collect into l_asset_tab
        from assets
        where to_date(business_dt,'DD-MON-YY') = to_date(SYSDATE,'DD-MON-YY');

        select asset_alloc_obj(acct.account_id,
                               sysdate,
                               systimestamp,
                               l_asset_tab)
        bulk collect into l_asset_alloc_tab
        from accounts acct;

        return l_asset_alloc_tab;
    end f_build_asset_allocation_obj;

    create or replace procedure p_test_asset_allocation
    as
      l_asset_alloc_tab asset_alloc_tab := asset_alloc_tab();
    begin
        select f_build_asset_allocation_obj()
        into l_asset_alloc_tab
        from dual;

        load_asset_allocation_pkg.p_process_asset_allocation(l_asset_alloc_tab);
end test_asset_allocation_pkg;
/