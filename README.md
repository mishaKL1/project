Témou tohto projektu je analýza trhu práce a aktivity spoločností na základe historických údajov o voľných pracovných miestach.
Pôvodný súbor údajov obsahuje primárne štruktúrované údaje. Tieto údaje zahŕňajú časové údaje (dátumy a aktivita uverejnenia pracovných ponúk), číselné údaje (počet voľných pracovných miest) a textové údaje vo forme popisov pracovných pozícií.
Účelom analýzy je analyzovať vývoj pracovných ponúk v čase a zhodnotiť ich využitie ako indikátora budúcej ekonomickej a firemnej výkonnosti.
Túto sadu údajov som si vybral, pretože poskytuje jedinečné „alternatívne údaje“ (voľné pracovné miesta), ktoré nám umožňujú sledovať ekonomické trendy.
Dáta podporujú investičnú analýzu a strategické plánovanie, čo umožňuje spoločnostiam a investorom robiť rozhodnutia na základe skutočného dopytu po pracovnej sile a prevádzkových zmien v personálnych politikách konkurentov.
Analýza sa zameria na identifikáciu korelácie medzi náborovou aktivitou (počet nových a uzavretých voľných pracovných miest) a stabilitou spoločností na trhu, ako aj na identifikáciu trendov v odvetví, pokiaľ ide o dopyt po konkrétnych profesiách.
 Predstavlenie tabuliek:
1.	JOB_RECORDS_SAMPLE - Centrálna tabuľka obsahujúca detaily o konkrétnych pracovných ponukách (lokalita, dátumy zverejnenia/stiahnutia, URL). Slúži na sledovanie dynamiky náboru.
2.	JOB_DESCRIPTIONS_SAMPLE - Obsahuje textové popisy prác prepojené cez JOB_HASH.
3.	PIT_COMPANY_REFERENCE_SAMPLE -Toto je adresár so základnými informáciami o spoločnostiach.
4.	CORE_COMPANY_ANALYTICS_SAMPLE - Agregované metriky na úrovni spoločnosti za konkrétne dni.
5.	CORE_TICKER_ANALYTICS_SAMPLE - Toto je tabuľka s hotovými dennými štatistikami pre akciové burzy, ktorá ukazuje, koľko voľných pracovných miest bolo v daný deň otvorených alebo uzavretých pre konkrétne akcie.
6.	ONET_TAXONOMY_2019_SAMPLE - Toto je adresár, ktorý kategorizuje pracovné ponuky do štandardných kategórií povolaní.
7.	COMPANY_TICKER_REFERENCE_SAMPLE - Toto je tabuľka prepojení, ktorá porovnáva interné ID spoločností s ich oficiálnymi burzovými indexmi.
8.	COMPANY_SCRAPE_LOG_SAMPLE - Technická tabuľka sledujúca proces zberu dát.

Star Schema:
V našej hviezdicovej modele máme dve tabuľky faktov a päťdimenzionálne tabuľky.
Použitie dvoch tabuliek faktov je nevyhnutné, pretože nemôžeme kombinovať údaje o všetkých voľných pracovných miestach za daný deň a podrobnosti o každom voľnom pracovnom mieste v jednej tabuľke faktov, pretože by to viedlo k logickým chybám vo výpočtoch.
Preto sa tabuľka FACT_JOB_ACTIVITY používa na výpočet „denných súčtov“ a tabuľka FACT_JOB_POSTINGS sa používa na výpočet podrobností o každom voľnom pracovnom mieste.
Sú prepojené pomocou zdieľaných dimenzionálnych tabuliek DIM_OCCUPATION a DIM_COMPANY.

FACT_JOB_ACTIVITY:
Primárny kľúč: fact_job_activity_id
Cudzie kľúče:  company_id , ticker_id , occupation_id
hlavné metriky:  created_job_count - počet novovytvorených voľných pracovných miest v daný deň ,  deleted_job_count - počet zrušené/obsadenych voľných pracovných miest v daný deň , unique_active_job_count - celkový počet voľných pracovných miest , active_duration - čas, kedy je voľné miesto otvorené.

FACT_JOB_POSTINGS:
Primárny kľúč: fact_job_post_id.
Cudzie kľúče: job_hash , company_id, occupation_id,location_id.
hlavné metriky: unmapped_location - technický príznak presnosti priradenia lokality.

DIM_COMPANY:
obsah: nazov firmy,LEI, naics, datum start a end.
vztah z faktami: 1:N do dvoch faktovych tabuliek.
typ SCD: 2 , Uchováva históriu zmien.

DIM_OCCUPATION:
obsah: nazvy profesii.
vztah z faktami: 1:N do dvoch faktovych tabuliek.
typ SCD: 1 , nové informácie prepisujú staré.

DIM_LOCATION:
obsah: geograficke udaje.
vztah z faktami: 1:n k FACT_JOB_POSTINGS.
typ SCD: 0 , fixovana data.

DIM_TICKER:
obsah:ticker, názov burzy a krajina obchodovania.
vztah z faktami: 1:n k FACT_JOB_ACTIVITY.
typ SCD: 2 Uchováva históriu zmien.

DIM_JOB:
obsah: informacie o prace - nazov , popis, url.
vztah z faktami: 1:n k FACT_JOB_POSTINGS.
typ SCD: 1 , nové informácie prepisujú staré.

Shubin Mykhailo
