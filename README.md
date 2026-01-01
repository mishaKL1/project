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


