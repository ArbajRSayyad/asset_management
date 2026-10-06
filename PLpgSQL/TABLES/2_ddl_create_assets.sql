-- This script is to create ASSETS table to store customer assets information
CREATE TABLE ASSETS
(
    ASSET_ID integer,
    BUSINESS_DT DATE NOT NULL,
    DESCRIPTION character varying(4000),
    USD_PRICE bigint NOT NULL,
    CONSTRAINT ASSETS_PK PRIMARY KEY (ASSET_ID,BUSINESS_DT)
);