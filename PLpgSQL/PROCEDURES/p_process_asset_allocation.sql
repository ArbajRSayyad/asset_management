create procedure p_process_asset_allocation(
                                            pi_asset_alloc_tab asset_alloc_tab[]
                                            )
language plpgsql
as
$$
declare
        l_act_ast_map_id bigint := 0;
begin
      if cardinality(pi_asset_alloc_tab) is null
      or cardinality(pi_asset_alloc_tab)=0
      then
            raise exception using errorcode = 'PZ001';
      else
        foreach act_ast in pi_asset_alloc_tab
        loop
            call pio_crt_act_ast_map(ARRAY[act_ast],l_act_ast_map_id);

            if l_act_ast_map_id is not null
            then
                insert into asset_allocation (act_ast_map_id, asset_id)
                select l_act_ast_map_id, al.asset_id
                from table(act_ast) paat
                cross join lateral (paat.assets_list) al(asset_id);
            end if;
        end loop;
      end if;
    exception
    when SQLSTATE 'PZ001'
    then raise notice 'Processing as per organizations rules.';
end;
$$;