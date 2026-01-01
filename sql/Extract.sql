create or replace table raw_jobs as seLECT * FROM RAW_SAMPLE_DATA.LINKUP.JOB_RECORDS_SAMPLE;
select * from raw_jobs;

create or replace table raw_jobs_description as select * from RAW_SAMPLE_DATA.LINKUP.JOB_DESCRIPTIONS_SAMPLE;
select * from raw_jobs_description;

create or replace table  raw_company_tickers as select * from RAW_SAMPLE_DATA.LINKUP.COMPANY_TICKER_REFERENCE_SAMPLE;
select * from raw_company_tickers;

create or replace table  raw_occupations as select * from RAW_SAMPLE_DATA.LINKUP.ONET_TAXONOMY_2019_SAMPLE;
select * from raw_occupations;

create or replace table  raw_company as select * from RAW_SAMPLE_DATA.LINKUP.PIT_COMPANY_REFERENCE_SAMPLE;
select * from raw_company;

create or replace table raw_core_ticker as select * from RAW_SAMPLE_DATA.LINKUP.CORE_COMPANY_ANALYTICS_SAMPLE;
select * from raw_core_ticker;

-- Účel: Kopírovanie surových dát z Snowflake Marketplace do staging tabuliek.  Zdroj: RAW_SAMPLE_DATA.LINKUP 