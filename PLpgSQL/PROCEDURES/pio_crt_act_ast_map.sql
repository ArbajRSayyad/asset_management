create or replace procedure pio_crt_act_ast_map(
                                        in pi_asset_alloc_tab asset_alloc_tab[],
                                        out po_ACCT_AST_MAP_ID integer
                                        )
language plpgsql
as
$$
declare
        l_new_ACCT_AST_MAP_ID integer;
        l_ex_ACCT_AST_MAP_ID integer;
begin
       select max(ACCT_AST_MAP_ID)
       into l_ex_ACCT_AST_MAP_ID
       from account_asset_map
       where account_id = pi_asset_alloc_tab[1].account_id
       and business_dt = pi_asset_alloc_tab[1].business_dt;

       if l_ex_ACCT_AST_MAP_ID is null
       then
            raise exception using errcode= 'PZ002';
       else
            if exists
                (
                    select al.asset_id
                    from unnest(pi_asset_alloc_tab) paat
                    cross join lateral unnest(paat.assets_list) al(asset_id)
                    except
                    select al.asset_id
                    from asset_allocation al
                    where ACCT_AST_MAP_ID = l_ex_ACCT_AST_MAP_ID
                )
                or exists
                (
                    select al.asset_id
                    from asset_allocation al
                    where ACCT_AST_MAP_ID = l_ex_ACCT_AST_MAP_ID
                    except
                    select al.asset_id
                    from unnest(pi_asset_alloc_tab) paat
                    cross join lateral unnest(paat.assets_list) al(asset_id)
            )
            then
                select max(ACCT_AST_MAP_ID)+1
                into l_new_ACCT_AST_MAP_ID
                from account_asset_map;

                insert into account_asset_map(
                                                ACCT_AST_MAP_ID,
                                                account_id,
                                                business_dt,
                                                map_from_tmstmp
                                                )
                values
                    (
                        l_new_ACCT_AST_MAP_ID,
                        pi_asset_alloc_tab[1].account_id,
                        pi_asset_alloc_tab[1].business_dt,
                        pi_asset_alloc_tab[1].map_from_timestamp
                    );

                update account_asset_map
                set map_to_tmstmp = pi_asset_alloc_tab[1].map_from_timestamp,
                active_ind = 'N',
                update_tmstmp = current_timestamp
                where ACCT_AST_MAP_ID = l_ex_ACCT_AST_MAP_ID;

                po_ACCT_AST_MAP_ID := l_new_ACCT_AST_MAP_ID;

            else
                po_ACCT_AST_MAP_ID := null;
            end if;
       end if;
    exception
    when SQLSTATE 'PZ002'
    then
        select coalesce(max(ACCT_AST_MAP_ID),1)+1
        into l_new_ACCT_AST_MAP_ID
        from account_asset_map;

        insert into account_asset_map(
                                      ACCT_AST_MAP_ID,
                                      account_id,
                                      business_dt,
                                      map_from_tmstmp
                                     )
                values
                    (
                        l_new_ACCT_AST_MAP_ID,
                        pi_asset_alloc_tab[1].account_id,
                        pi_asset_alloc_tab[1].business_dt,
                        pi_asset_alloc_tab[1].map_from_timestamp
                    );
        po_ACCT_AST_MAP_ID := l_new_ACCT_AST_MAP_ID;
end;
$$;