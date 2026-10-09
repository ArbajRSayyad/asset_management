create or replace procedure p_load_acct_ast_alloc_json(p_business_dt date)
language plpgsql
as
$$
begin
	begin
		insert into ACCOUNT_ASSET_ALLOC_JSON (account_id, business_dt,insert_tmstmp,acct_ast_alloc_json)
	with account_asset_alloc as
		(
		select act.account_id, acct_fullname,coalesce(aam.business_dt,'1900-01-01')as business_dt,map_from_tmstmp,
		json_agg(jsonb_build_object('asset_id', aa.asset_id,
										'usd_price', ast.usd_price,
									 	'description', ast.description)
						) as assets_list
		from accounts act
		left join account_asset_map aam
		on act.account_id = aam.account_id
		and active_ind = 'Y'
		left join asset_allocation aa
		on aam.acct_ast_map_id = aa.acct_ast_map_id
		left join assets ast
		on aa.asset_id = ast.asset_id
		and aam.business_dt = ast.business_dt
		and aam.business_dt = p_business_dt
		group by act.account_id,acct_fullname,aam.business_dt,map_from_tmstmp
	)
	select account_id,business_dt,
	current_timestamp::timestamp as insert_tmstmp,
	to_json(account_asset_alloc) acct_ast_alloc_json
	from account_asset_alloc
	ON CONFLICT(account_id,business_dt)
	DO UPDATE SET (insert_tmstmp,acct_ast_alloc_json) = (now(),EXCLUDED.acct_ast_alloc_json);
	exception
	when others
	then
		RAISE NOTICE 'Failure to load account asset alloc json with code: % and error: %',
		SQLSTATE,SQLERRM;
	end;
end;
$$;