create or replace table dim_occupation as(
select  row_number() over(order by ONET_OCCUPATION_CODE) as occupation_id, --vytvorenie jedinečného ID pre každý záznam
ONET_OCCUPATION_CODE
from (select distinct ONET_OCCUPATION_CODE from raw_occupations) --odstránenie duplicitných hodnôt z operačných dát
);
--select * from dim_occupation; -- kontrolný výpis dát

create or replace table dim_company as(
select company_id,company_name, company_url as url, LEI,naics_code,open_perm_id,start_date,end_date from raw_company 
);
--select * from dim_company; -- kontrolný výpis dát

create or replace table dim_job as (
select j.job_hash,j.title,j.url,d.job_description 
from raw_jobs j inner join  raw_jobs_description d on j.job_hash = d.job_hash 
);
--select * from dim_job; -- kontrolný výpis dát

create or replace table dim_location as (
select row_number() over(order by city,state,country) as locate_id, --vytvorenie jedinečného ID pre každý záznam
city, state,country ,zip 
from (select distinct city, state, country, zip from raw_jobs) --odstránenie duplicitných hodnôt z operačných dát
);
--select * from dim_location; -- kontrolný výpis dát


create or replace table fact_job_posting as (
select row_number() over(order by j.created) as fact_job_postingid, --vytvorenie jedinečného ID pre každý záznam
j.job_hash,c.company_id,o.occupation_id,l.locate_id,j.created,j.LAST_CHECKED,j.LAST_UPDATED,j.UNMAPPED_LOCATION
from raw_jobs j inner join dim_company c on j.company_id = c.company_id inner join (select distinct job_hash, onet_occupation_code from raw_occupations) o1 on j.job_hash = o1.job_hash inner join  dim_occupation o on o1.onet_occupation_code = o.onet_occupation_code left join dim_location l on j.city = l.city and j.state = l.state and j.country = l.country
qualify row_number() over(partition by j.job_hash order by j.created desc) = 1 --odstránenie duplikátov
);
--select * from fact_job_posting; -- kontrolný výpis dát
