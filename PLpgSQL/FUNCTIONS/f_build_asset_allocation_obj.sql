create or replace function f_build_asset_allocation_obj()
returns setof asset_alloc_tab
language plpgsql
as
$$
declare
        l_assets integer[];
begin
        select array_agg(al.asset_id)
        into l_assets
        from assets al
        where business_dt = current_date;

        RETURN QUERY
        select acct.account_id,
               current_date,
               current_timestamp::timestamp,
               l_assets
        from accounts as acct;
end;
$$;