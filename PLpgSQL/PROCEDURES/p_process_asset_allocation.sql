create or replace procedure p_process_asset_allocation(
                                            pi_asset_alloc_tab asset_alloc_tab[]
                                            )
language plpgsql
as
$$
declare
        l_ACCT_AST_MAP_ID integer := 0;
		l_act_ast_tab asset_alloc_tab;
begin
      if cardinality(pi_asset_alloc_tab) is null
      or cardinality(pi_asset_alloc_tab)=0
      then
            raise exception using errcode = 'PZ001';
      else
        foreach l_act_ast_tab in ARRAY pi_asset_alloc_tab
        loop
            call pio_crt_act_ast_map(ARRAY[l_act_ast_tab],l_ACCT_AST_MAP_ID);

            if l_ACCT_AST_MAP_ID is not null
            then
                insert into asset_allocation (ACCT_AST_MAP_ID, asset_id)
                select l_ACCT_AST_MAP_ID, al.asset_id
                from unnest((l_act_ast_tab).assets_list) al(asset_id);
            end if;
        end loop;
      end if;
    exception
    when SQLSTATE 'PZ001'
    then raise notice 'Processing as per organizations rules.';
end;
$$;