create table ACCOUNT_ASSET_ALLOC_JSON
(   account_id integer,
    business_dt date,
    INSERT_TMSTMP TIMESTAMP DEFAULT NOW() NOT NULL,
    acct_ast_alloc_json jsonb not null
    constraint acct_ast_json_pk primary key (account_id,business_dt)
 );