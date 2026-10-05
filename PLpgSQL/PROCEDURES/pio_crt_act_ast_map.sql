create or replace procedure pio_crt_act_ast_map(
                                        in pi_asset_alloc_tab asset_alloc_tab[],
                                        out po_act_ast_map_id bigint
                                        )
language plpgsql
as
$$
declare
        l_new_act_ast_map_id bigint;
        l_ex_act_ast_map_id bigint;
begin
       select max(act_ast_map_id)
       into l_ex_act_ast_map_id
       from account_asset_map
       where account_id = pi_asset_alloc_tab[1].account_id
       and business_dt = pi_asset_alloc_tab[1].business_dt;

       if l_ex_act_ast_map_id is null
       then
            raise exception using errorcode= 'PZ002';
       else
            if exists
                (
                    select al.asset_id
                    from unnest(pi_asset_alloc_tab) paat
                    cross join lateral unnest(paat.assets_list) al(asset_id)
                    except
                    select al.asset_id
                    from asset_allocation
                    where act_ast_map_id = l_ex_act_ast_map_id
                )
                or exists
                (
                    select al.asset_id
                    from asset_allocation
                    where act_ast_map_id = l_ex_act_ast_map_id
                    except
                    select al.asset_id
                    from unnest(pi_asset_alloc_tab) paat
                    cross join lateral unnest(paat.assets_list) al(asset_id)
            )
            then
                select max(act_ast_map_id)+1
                into l_new_act_ast_map_id
                from account_asset_map;

                insert into account_asset_map(
                                                act_ast_map_id
                                                account_id,
                                                business_dt,
                                                map_from_tmstmp
                                                )
                values
                    (
                        l_new_act_ast_map_id,
                        pi_asset_alloc_tab[1].account_id,
                        pi_asset_alloc_tab[1].business_dt,
                        pi_asset_alloc_tab[1].map_from_tmstmp
                    );

                update account_asset_map
                set map_to_tmstmp = pi_asset_alloc_tab[1].map_from_tmstmp,
                active_ind = 'N'
                update_tmstmp = current_timestamp
                where act_ast_map_id = l_ex_act_ast_map_id;

                po_act_ast_map_id := l_new_act_ast_map_id

            else
                po_act_ast_map_id := null;
            end if;
       end of;
    exception
    when SQLSTATE 'PZ002'
    then
        select coalesce(max(act_ast_map_id),1)+1
        into l_new_act_ast_map_id
        from account_asset_map;

        insert into account_asset_map(
                                      act_ast_map_id
                                      account_id,
                                      business_dt,
                                      map_from_tmstmp
                                     )
                values
                    (
                        l_new_act_ast_map_id,
                        pi_asset_alloc_tab[1].account_id,
                        pi_asset_alloc_tab[1].business_dt,
                        pi_asset_alloc_tab[1].map_from_tmstmp
                    );
        po_act_ast_map_id := l_new_act_ast_map_id
end;
$$;