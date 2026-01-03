<h2>ELT proces datasetu RAW_SAMPLE_DATA</h2>
<h2>1 Úvod a popis zdrojových dát</h2>
Témou tohto projektu je analýza trhu práce a aktivity spoločností na základe historických údajov o voľných pracovných miestach.
Pôvodný súbor údajov obsahuje primárne štruktúrované údaje. Tieto údaje zahŕňajú časové údaje (dátumy a aktivita uverejnenia pracovných ponúk), číselné údaje (počet voľných pracovných miest) a textové údaje vo forme popisov pracovných pozícií.
Účelom analýzy je analyzovať vývoj pracovných ponúk v čase a zhodnotiť ich využitie ako indikátora budúcej ekonomickej a firemnej výkonnosti.
Túto sadu údajov som si vybral, pretože poskytuje jedinečné „alternatívne údaje“ (voľné pracovné miesta), ktoré nám umožňujú sledovať ekonomické trendy.
Dáta podporujú investičnú analýzu a strategické plánovanie, čo umožňuje spoločnostiam a investorom robiť rozhodnutia na základe skutočného dopytu po pracovnej sile a prevádzkových zmien v personálnych politikách konkurentov.
Analýza sa zameria na identifikáciu korelácie medzi náborovou aktivitou (počet nových a uzavretých voľných pracovných miest) a stabilitou spoločností na trhu, ako aj na identifikáciu trendov v odvetví, pokiaľ ide o dopyt po konkrétnych profesiách.

<img width="1619" height="950" alt="originalERD" src="https://github.com/user-attachments/assets/c849a55e-7f75-48be-9154-5e4ee33f56f2" />

 Predstavlenie tabuliek:
1.	JOB_RECORDS_SAMPLE - Centrálna tabuľka obsahujúca detaily o konkrétnych pracovných ponukách (lokalita, dátumy zverejnenia/stiahnutia, URL). Slúži na sledovanie dynamiky náboru.
2.	JOB_DESCRIPTIONS_SAMPLE - Obsahuje textové popisy prác prepojené cez JOB_HASH.
3.	PIT_COMPANY_REFERENCE_SAMPLE -Toto je adresár so základnými informáciami o spoločnostiach.
4.	CORE_COMPANY_ANALYTICS_SAMPLE - Agregované metriky na úrovni spoločnosti za konkrétne dni.
5.	CORE_TICKER_ANALYTICS_SAMPLE - Toto je tabuľka s hotovými dennými štatistikami pre akciové burzy, ktorá ukazuje, koľko voľných pracovných miest bolo v daný deň otvorených alebo uzavretých pre konkrétne akcie.
6.	ONET_TAXONOMY_2019_SAMPLE - Toto je adresár, ktorý kategorizuje pracovné ponuky do štandardných kategórií povolaní.
7.	COMPANY_TICKER_REFERENCE_SAMPLE - Toto je tabuľka prepojení, ktorá porovnáva interné ID spoločností s ich oficiálnymi burzovými indexmi.
8.	COMPANY_SCRAPE_LOG_SAMPLE - Technická tabuľka sledujúca proces zberu dát.

<h2>2 hviezdicova model</h2>
Star Schema:
V našej hviezdicovej modele máme dve tabuľky faktov a päťdimenzionálne tabuľky.
Použitie dvoch tabuliek faktov je nevyhnutné, pretože nemôžeme kombinovať údaje o všetkých voľných pracovných miestach za daný deň a podrobnosti o každom voľnom pracovnom mieste v jednej tabuľke faktov, pretože by to viedlo k logickým chybám vo výpočtoch.
Preto sa tabuľka FACT_JOB_ACTIVITY používa na výpočet „denných súčtov“ a tabuľka FACT_JOB_POSTINGS sa používa na výpočet podrobností o každom voľnom pracovnom mieste.
Sú prepojené pomocou zdieľaných dimenzionálnych tabulki DIM_COMPANY.

<img width="1487" height="655" alt="star_schema" src="https://github.com/user-attachments/assets/6a7c9d2a-a897-4945-8796-f27bba8f243e" />

Napriek tomu, že použitie dvoch tabuliek faktov je z pohľadu modelovania dát korektné a zodpovedá schéme súhvezdia faktov, v rámci tohto projektu sme sa rozhodli model zjednodušiť.
Cieľom projektu je prezentovať klasickú hviezdicovú schému, ktorá pozostáva z jednej tabuľky faktov a viacerých dimenzionálnych tabuliek. Z tohto dôvodu sme sa zamerali na jeden hlavný biznis proces – detailné informácie o voľných pracovných miestach.
Tabuľka FACT_JOB_ACTIVITY, ktorá slúži na výpočet agregovaných denných súčtov, bola z finálneho modelu vynechaná
Výsledná dátová štruktúra tak obsahuje jednu tabuľku faktov a štyri dimenzionálne tabuľky, čím lepšie zodpovedá klasickej hviezdicovej schéme.

<img width="919" height="740" alt="star_schema" src="https://github.com/user-attachments/assets/793d372b-c5ba-4259-a003-5c9d2d1ece11" />

FACT_JOB_POSTINGS:
Primárny kľúč: fact_job_post_id.
Cudzie kľúče: job_hash , company_id, occupation_id,location_id.
hlavné metriky: unmapped_location - technický príznak presnosti priradenia lokality, created a updated, checked - parametre posledných interakcií s voľnými pracovnými miestami.

DIM_COMPANY:
obsah: nazov firmy,LEI, naics, datum start a end.
vztah z faktami: 1:N k FACT_JOB_POSTINGS
typ SCD: 2 , Uchováva históriu zmien.

DIM_OCCUPATION:
obsah: nazvy profesii.
vztah z faktami: 1:N k FACT_JOB_POSTINGS
typ SCD: 1 , nové informácie prepisujú staré.

DIM_LOCATION:
obsah: geograficke udaje.
vztah z faktami: 1:n k FACT_JOB_POSTINGS.
typ SCD: 0 , fixovana data.

DIM_JOB:
obsah: informacie o prace - nazov , popis, url.
vztah z faktami: 1:n k FACT_JOB_POSTINGS.
typ SCD: 1 , nové informácie prepisujú staré.

<h2>3 ELT proces v Snowflake</h2>
<h2>3.1 Extract</h2>
V tejto fáze sa údaje získavajú z pôvodných zdrojov bez akejkoľvek transformácie.

```sql
create or replace table raw_jobs as seLECT * FROM RAW_SAMPLE_DATA.LINKUP.JOB_RECORDS_SAMPLE;
create or replace table raw_jobs_description as select * from RAW_SAMPLE_DATA.LINKUP.JOB_DESCRIPTIONS_SAMPLE;
create or replace table  raw_occupations as select * from RAW_SAMPLE_DATA.LINKUP.ONET_TAXONOMY_2019_SAMPLE;
create or replace table  raw_company as select * from RAW_SAMPLE_DATA.LINKUP.PIT_COMPANY_REFERENCE_SAMPLE;
```
<h2>3.2 , 3.3 Load a Transform</h2>
V tomto kroku sa údaje extrahované zo zdrojových kódov (tabuľky raw_*) načítajú do cieľovej schémy a súčasne sa transformujú na analytické účely.
Tabuľky dimenzií (dim_company, dim_occupation, dim_job, dim_location) sú generované s jedinečnými kľúčmi a údajmi zbavenými duplikátov.
window funcion (ROW_NUMBER() OVER(...)) a filtre (DISTINCT, QUALIFY) sa používajú na odstránenie duplikátov a správne generovanie jedinečných záznamov vo faktoch.

```sql
create or replace table dim_occupation as(
select  row_number() over(order by ONET_OCCUPATION_CODE) as occupation_id, --vytvorenie jedinečného ID pre každý záznam
ONET_OCCUPATION_CODE
from (select distinct ONET_OCCUPATION_CODE from raw_occupations)
);
create or replace table dim_company as(
select company_id,company_name, company_url as url, LEI,naics_code,open_perm_id,start_date,end_date from raw_company
);
create or replace table dim_job as (
select j.job_hash,j.title,j.url,d.job_description 
from raw_jobs j inner join  raw_jobs_description d on j.job_hash = d.job_hash
);
create or replace table dim_location as (
select row_number() over(order by city,state,country) as locate_id, --vytvorenie jedinečného ID pre každý záznam
city, state,country ,zip from (select distinct city, state, country, zip from raw_jobs)
);
create or replace table fact_job_posting as (
select row_number() over(order by j.created) as fact_job_postingid, --vytvorenie jedinečného ID pre každý záznam
j.job_hash,c.company_id,o.occupation_id,l.locate_id,j.created,j.LAST_CHECKED,j.LAST_UPDATED,j.UNMAPPED_LOCATION
from raw_jobs j inner join dim_company c on j.company_id = c.company_id inner join (select distinct job_hash, onet_occupation_code from raw_occupations) o1 on j.job_hash = o1.job_hash inner join  dim_occupation o on o1.onet_occupation_code = o.onet_occupation_code left join dim_location l on j.city = l.city and j.state = l.state and j.country = l.country
qualify row_number() over(partition by j.job_hash order by j.created desc) = 1 --odstránenie duplikátov
);
```

<h2>4 Vizualizácia dát</h2>:

1)Top 10 krajín podľa počtu voľných pracovných miest:  
```sql
SELECT l.country, COUNT(*) AS total_jobs
FROM fact_job_posting f JOIN dim_location l ON f.locate_id = l.locate_id 
GROUP BY l.country 
ORDER BY total_jobs DESC LIMIT 10;
```
<img width="1584" height="426" alt="1" src="https://github.com/user-attachments/assets/f88b10b4-ae68-4834-a059-8c9fe77f80e0" />

2)5 najžiadanejších profesií (ONET):  
```sql
SELECT o.onet_occupation_code, COUNT(*) AS job_count FROM fact_job_posting f JOIN dim_occupation o ON f.occupation_id = o.occupation_id
GROUP BY o.onet_occupation_code
ORDER BY job_count DESC LIMIT 5;
```
<img width="1609" height="687" alt="2" src="https://github.com/user-attachments/assets/2aede71b-04ad-4764-ab5f-000c24a41126" />

3)Dynamika nových voľných pracovných miest:  
```sql
select trunc(created,'MONTH') as posting_date , count(*) as pocet_job  from fact_job_posting group by created;
```
<img width="1322" height="690" alt="3" src="https://github.com/user-attachments/assets/da4c10b3-0508-4285-b70e-ba250e2948c7" />

4)Top 3 spoločnosti podľa počtu pracovných ponúk:  
```sql
select  c.company_name, count(distinct f.job_hash) as num_jobs
from fact_job_posting f
inner join dim_company c on f.company_id = c.company_id
group by c.company_name order by num_jobs desc limit 3;
```
<img width="1316" height="270" alt="4" src="https://github.com/user-attachments/assets/8cfaf6f2-64da-478a-aa54-7b2c77e16674" />

5)Sektorová štruktúra dopytu:  
```sql
SELECT c.naics_code, COUNT(f.fact_job_postingid) AS job_count
FROM fact_job_posting f
JOIN dim_company c ON f.company_id = c.company_id
GROUP BY c.naics_code ORDER BY job_count DESC;
```
<img width="1608" height="445" alt="5" src="https://github.com/user-attachments/assets/ce380167-a82b-4d00-937f-b2bcbac2c5fa" />


Shubin Mykhailo
