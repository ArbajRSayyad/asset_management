-- This script is to create ACCOUNTS table to store customer account information
CREATE TABLE ACCOUNTS
(
    ACCOUNT_ID integer,
    ACCT_FULLNAME character varying (1000),
    ACCOUNT_ACTIVE_IND character(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT ACCOUNTS_PK PRIMARY KEY (ACCOUNT_ID),
    CONSTRAINT ACCOUNT_ACTIVE_CK CHECK (ACCOUNT_ACTIVE_IND IN ('Y','N'))
);