create or replace table dim_ticker as(
select  row_number() over(order by ticker_symbol) as ticker_id,
ticker_symbol, 
STOCK_EXCHANGE_NAME,
STOCK_EXCHANGE_COUNTRY,
start_date ,
end_date,
primary_flag
from raw_company_tickers
);
select * from dim_ticker;

create or replace table dim_occupation as(
select  row_number() over(order by ONET_OCCUPATION_CODE) as occupation_id,
ONET_OCCUPATION_CODE
from (select distinct ONET_OCCUPATION_CODE from raw_occupations)
);
select * from dim_occupation;

create or replace table dim_company as(
select company_id,company_name, company_url as url, LEI,naics_code,open_perm_id,start_date,end_date from raw_company
);
select * from dim_company;

create or replace table dim_job as (
select j.job_hash,j.title,j.url,d.job_description 
from raw_jobs j inner join  raw_jobs_description d on j.job_hash = d.job_hash
);
select * from dim_job;

create or replace table dim_location as (
select row_number() over(order by city,state,country) as locate_id,
city, state,country ,zip from (select distinct city, state, country, zip from raw_jobs)
);
select * from dim_location;

create or replace table fact_job_activity as (
select row_number() over(order by  d.day , d.company_id) as fact_job_activityid,
d.company_id,t.ticker_id,d.day as date, d.created_job_count, d.deleted_job_count,d.unique_active_job_count,d.active_duration
from raw_core_ticker d inner join raw_company c on d.company_id = c.company_id inner join raw_company_tickers r on c.company_id = r.company_id inner join dim_ticker t on r.ticker_symbol = t.ticker_symbol 
where t.primary_flag = true
);
select * from fact_job_activity;

create or replace table fact_job_posting as (
select row_number() over(order by j.created) as fact_job_postingid,
j.job_hash,
c.company_id,
o.occupation_id,
l.locate_id,
j.created,
j.LAST_CHECKED,
j.LAST_UPDATED,
j.UNMAPPED_LOCATION
from raw_jobs j inner join dim_company c on j.company_id = c.company_id inner join (select distinct job_hash, onet_occupation_code from raw_occupations) o1 on j.job_hash = o1.job_hash inner join 
dim_occupation o on o1.onet_occupation_code = o.onet_occupation_code left join dim_location l on j.city = l.city and j.state = l.state and j.country = l.country
qualify row_number() over(partition by j.job_hash order by j.created desc) = 1
);

select * from fact_job_posting;