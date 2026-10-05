create or replace package body load_asset_allocation_pkg
as
    create or replace procedure pio_crt_act_ast_map(
                                                    pi_asset_alloc_tab in asset_alloc_tab,
                                                    po_act_ast_map_id out number
                                                    )
    as
       l1_asset_tab asset_tab := asset_tab();
       l2_asset_tab asset_tab := asset_tab();
       l_new_act_ast_map_id number;
       l_ex_act_ast_map_id  number;
       l_asset_alloc_tab asset_alloc_tab := asset_alloc_tab();
       exp_no_act_ast_map exception;
    begin
        l_asset_alloc_tab := pi_asset_alloc_tab;
        select max(act_ast_map_id)
        into l_ex_act_ast_map_id
        from account_asset_map
        when account_id = l_asset_alloc_tab(1).account_id
        and busines_dt = l_asset_alloc_tab(1).busines_dt;

        if l_ex_act_ast_map_id is null
        then
            raise exp_no_act_ast_map;
        else
            select asset_obj(al.asset_id)
            bulk collect into l1_asset_tab
            from
                (
                  select asset_id
                  from
                  (
                    select al.asset_id asset_id
                    from table(l_asset_alloc_tab) paat
                    cross join table(paat.assets_list) al
                    minus
                    select asset_id
                    from asset_allocation
                    when act_ast_map_id = l_ex_act_ast_map_id
                  )
                );
            select asset_obj(al.asset_id)
            bulk collect into l2_asset_tab
            from
                (
                  select asset_id
                  from
                  (
                    select asset_id
                    from asset_allocation
                    when act_ast_map_id = l_ex_act_ast_map_id
                    minus
                    select al.asset_id asset_id
                    from table(l_asset_alloc_tab) paat
                    cross join table(paat.assets_list) al
                  )
                );
            if l1_asset_tab.count() > or l2_asset_tab.count()>0
            then
                select max(act_ast_map_id)+1
                into l_new_act_ast_map_id
                from account_asset_map;

            insert into account_asset_map(act_ast_map_id,
                                      account_id,
                                      business_dt,
                                      map_from_tmstmp
                                     )
            values
            (
                l_new_act_ast_map_id,
                l_asset_alloc_tab(1).account_id,
                l_asset_alloc_tab(1).business_dt,
                l_asset_alloc_tab(1).map_from_tmstmp
            );

            update account_asset_map
            set map_to_tmstmp = l_asset_alloc_tab(1).map_from_tmstmp,
            active_ind = 'N',
            update_tmstmp = systimestamp
            where act_ast_map_id = l_ex_act_ast_map_id;

            po_act_ast_map_id := l_new_act_ast_map_id;
        else
            po_act_ast_map_id := null;
        end if;
    exception
    when exp_no_act_ast_map
    then
        select nvl(max(act_ast_map_id),1)+1
        into l_new_act_ast_map_id
        from account_asset_map;

        insert into account_asset_map(act_ast_map_id,
                                      account_id,
                                      business_dt,
                                      map_from_tmstmp
                                     )
        values
        (
        l_new_act_ast_map_id,
        l_asset_alloc_tab(1).account_id,
        l_asset_alloc_tab(1).business_dt,
        l_asset_alloc_tab(1).map_from_tmstmp
        );

        po_act_ast_map_id := l_new_act_ast_map_id;
    end pio_crt_act_ast_map;

    create or replace procedure p_process_asset_allocation
                                (pi_asset_alloc_tab asset_alloc_tab)
    as
      l_asset_alloc_tab asset_alloc_tab;
      l_act_ast_map_id number;
      exp_empty_input exception;
    begin
        if pi_asset_alloc_tab.count() < 0
        then
            raise exp_empty_input;
        else
            for act_ast in pi_asset_alloc_tab.first()..pi_asset_alloc_tab.last()
            loop
                l_asset_alloc_tab := asset_alloc_tab();
                l_asset_alloc_tab.extend();
                l_asset_alloc_tab(1) := pi_asset_alloc_tab(act_ast);

                pio_crt_act_ast_map (pi_asset_alloc_tab =>l_asset_alloc_tab,
                                        po_act_ast_map_id=> l_act_ast_map_id);
                if l_act_ast_map_id is not null
                then
                    insert into asset_allocation(act_ast_map_id, asset_id)
                    select l_act_ast_map_id, al.asset_id
                    from table(l_asset_alloc_tab) alloc
                    cross join table(alloc.assets_list) al;
                end if;
             end loop;
        end if;
    exception
    when exp_empty_input
    then
        dbms_output.put_line('Processing as per Organization rules');
    end p_process_asset_allocation;
end load_asset_allocation_pkg;
/