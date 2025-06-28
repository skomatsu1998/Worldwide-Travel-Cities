

select COUNT(*)
from worldwide_travel_cities_dataset;


select 
	id,
	key::int as _month,
	(value ->> 'avg')::numeric as average,
	(value ->> 'max')::numeric as maximum,
	(value ->> 'min')::numeric as minimum
from "Original".worldwide_travel_cities_dataset, 
 jsonb_each(avg_temp_monthly::jsonb) as t(key, value); 

drop table if exists temperature_info;
Create temporary table temperature_info AS
select 
id, 
-- average months
AVG(CASE WHEN _month = 1 THEN average end) AS January_avg,
AVG(case when _month = 2 then average end) as February_avg,
AVG(case when _month = 3 then average end) as March_avg,
AVG(case when _month = 4 then average end) as April_avg,
AVG(case when _month = 5 then average end) as May_avg,
AVG(case when _month = 6 then average end) as June_avg,
AVG(CASE WHEN _month = 7 THEN average end) AS July_avg,
AVG(case when _month = 8 then average end) as August_avg,
AVG(case when _month = 9 then average end) as September_avg,
AVG(case when _month = 10 then average end) as October_avg,
AVG(case when _month = 11 then average end) as November_avg,
AVG(case when _month = 12 then average end) as December_avg,

-- max
AVG(CASE WHEN _month = 1 THEN maximum end) AS January_max,
AVG(case when _month = 2 then maximum end) as February_max,
AVG(case when _month = 3 then maximum end) as March_max,
AVG(case when _month = 4 then maximum end) as April_max,
AVG(case when _month = 5 then maximum end) as May_max,
AVG(case when _month = 6 then maximum end) as June_max,
AVG(CASE WHEN _month = 7 THEN maximum end) AS July_max,
AVG(case when _month = 8 then maximum end) as August_max,
AVG(case when _month = 9 then maximum end) as September_max,
AVG(case when _month = 10 then maximum end) as October_max,
AVG(case when _month = 11 then maximum end) as November_max,
AVG(case when _month = 12 then maximum end) as December_max,

-- min
AVG(case WHEN _month = 1 THEN minimum end) AS January_min,
AVG(case when _month = 2 then minimum end) as February_min,
AVG(case when _month = 3 then minimum end) as March_min,
AVG(case when _month = 4 then minimum end) as April_min,
AVG(case when _month = 5 then minimum end) as May_min,
AVG(case when _month = 6 then minimum end) as June_min,
AVG(CASE WHEN _month = 7 THEN minimum end) AS July_min,
AVG(case when _month = 8 then minimum end) as August_min,
AVG(case when _month = 9 then minimum end) as September_min,
AVG(case when _month = 10 then minimum end) as October_min,
AVG(case when _month = 11 then minimum end) as November_min,
AVG(case when _month = 12 then minimum end) as December_min
from 
(
	select 
	id,
	key::int as _month,
	(value ->> 'avg')::numeric as average,
	(value ->> 'max')::numeric as maximum,
	(value ->> 'min')::numeric as minimum
	from worldwide_travel_cities_dataset, 
	jsonb_each(avg_temp_monthly::jsonb) as t(key, value)
)sub
group by id;


-- ideal_duration 
select *
from worldwide_travel_cities_dataset; 



select *
from temperature_info; 

-- joining these two tables together 
create table temporary_table_temperature_inc as 
select t.id, w.city, w.country, w.region, w.short_description, w.latitude, w.longitude, w.ideal_durations, w.budget_level, w.culture, w.adventure, w.nature, w.beaches, w.nightlife, w.cuisine, w.wellness, w.urban, w.seclusion,
t.January_avg, t.February_avg, t.March_avg, t.April_avg, t.May_avg, t.June_avg, t.July_avg, t.August_avg, t.September_avg, t.October_avg, t.November_avg, t.December_avg,
t.January_max, t.February_max, t.March_max, t.April_max, t.May_max, t.June_max, t.July_max, t.August_max, t.September_max, t.October_max, t.November_max, t.December_max,
t.January_min, t.February_min, t.March_min, t.April_min, t.May_min, t.June_min, t.July_min, t.August_min, t.September_min, t.October_min, t.November_min, t.December_min
from worldwide_travel_cities_dataset w
join temperature_info t on t.id = w.id;


-- labeling columns 
create table actual.detailed_view as 
select *
from "Original".temporary_table_temperature_inc;

-- adding new columns to describe the destination south or north
alter table actual.detailed_view 
add North_or_South VARCHAR, 

select *
from actual.detailed_view ;

-- adding new columns to describe the destination south or north
alter table actual.detailed_view 
add Nature_destination VARCHAR, 
add Cultural_destination VARCHAR, 
add Leisure_destination VARCHAR;


-- also adding if the destinations with different characteristics 
update actual.detailed_view 
set North_or_South = case
	when longitude > 0 then 'North'
	when longitude < 0 then 'South'
end,

Nature_destination = case
	when wellness > 3 and nature > 3 and adventure > 3 then 'Yes' else 'No' 
	end,

Cultural_destination = case
	when culture > 3 and cuisine > 3 then 'Yes' else 'no' 
	end,

Leisure_destination = case
	when urban  > 3 and nightlife > 3 then 'Yes' else 'no' end;




select *
from actual.detailed_view ;

-- calculating average score for all three destination categories 


alter table actual.detailed_view 
add top_nature_average numeric,
add top_culture_average numeric,
add top_leisure_average numeric;

-- adding the average score for those categories 
update actual.detailed_view 
set 
top_nature_average = case
	when nature_destination = 'Yes' then (wellness + nature + adventure) / 3
	else 0
	end,

top_culture_average = case
	when cultural_destination = 'Yes' then (culture + cuisine) / 2 
	else 0
	end,

top_leisure_average = case 
	when leisure_destination = 'Yes' then (urban + nightlife) / 2 
	else 0
end;



select *
from actual.detailed_view dv;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--                                 Creating a new view (nature)
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
create table actual.Top_nature_country as 

with nature_country as (
select country, avg( wellness + nature + adventure) / 3 as average_nature
from actual.detailed_view 
group by country)

select country, average_nature,
Rank() over (order by average_nature desc) as rank
from nature_country;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--                                 Creating a new view (cultural)
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
create table actual.Top_cultural_country as 

with cultural_country as (
select country, avg( culture + cuisine) / 2 as average_culture
from actual.detailed_view 
group by country)

select country, average_culture,
Rank() over (order by average_culture desc) as rank
from cultural_country;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--                                 Creating a new view (cultural)
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
create table  actual.Top_leisure_country as 

with leisure_country as (
select country, avg( urban + nightlife) / 2 as average_leisure
from actual.detailed_view 
group by country)

select country, average_leisure,
Rank() over (order by average_leisure desc) as rank
from leisure_country;

-- cross check with the bargraph Top Countries leisure 
with average_of_nightife_n_urban as(
select  country, AVG(nightlife + urban) as average
from actual.detailed_view 
group by country)

select 
country,  
average,
rank() over (order by average desc)
from average_of_nightife_n_urban;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--                                 adding the temperature, affordability and short description (nature)
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

with temporary_affordability_table as(
select *
from (
select *,
rank() over (partition by country order by _count desc) as rank
from (
select country, budget_level, count(budget_level) as _count
from actual.detailed_view
group by country, budget_level
)sub)
where rank = 1
) 

-- joining table 
select tn.country, tn.average_nature, tn.rank, tmp.budget_level
from actual.Top_nature_country tn
left join temporary_affordability_table tmp on tn.country = tmp.country;

-- update the table for each of all
-- nature table
alter table actual.Top_nature_country
add budget_level varchar;


UPDATE actual.Top_nature_country tn
SET budget_level = tmp.budget_level
FROM (
  SELECT *
  FROM (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY _count DESC) AS rank
    FROM (
      SELECT country, budget_level, COUNT(budget_level) AS _count
      FROM actual.detailed_view
      GROUP BY country, budget_level
    ) sub
  ) ranked
  WHERE rank = 1
) tmp
WHERE tn.country = tmp.country;

-- cultural table
alter table actual.Top_cultural_country
add budget_level varchar;


UPDATE actual.Top_cultural_country tn
SET budget_level = tmp.budget_level
FROM (
  SELECT *
  FROM (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY _count DESC) AS rank
    FROM (
      SELECT country, budget_level, COUNT(budget_level) AS _count
      FROM actual.detailed_view
      GROUP BY country, budget_level
    ) sub
  ) ranked
  WHERE rank = 1
) tmp
WHERE tn.country = tmp.country;


-- leisure table
alter table actual.Top_leisure_country
add budget_level varchar;


UPDATE actual.Top_leisure_country tn
SET budget_level = tmp.budget_level
FROM (
  SELECT *
  FROM (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY _count DESC) AS rank
    FROM (
      SELECT country, budget_level, COUNT(budget_level) AS _count
      FROM actual.detailed_view
      GROUP BY country, budget_level
    ) sub
  ) ranked
  WHERE rank = 1
) tmp
WHERE tn.country = tmp.country;

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--                           adding the temperature data as well
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

select *
from actual.detailed_view dv ;
-- adding new columns for temperature 
ALTER TABLE actual.top_nature_country
ADD COLUMN jan_avg FLOAT,
ADD COLUMN feb_avg FLOAT,
ADD COLUMN mar_avg FLOAT,
ADD COLUMN apr_avg FLOAT,
ADD COLUMN may_avg FLOAT,
ADD COLUMN jun_avg FLOAT,
ADD COLUMN jul_avg FLOAT,
ADD COLUMN aug_avg FLOAT,
ADD COLUMN sep_avg FLOAT,
ADD COLUMN oct_avg FLOAT,
ADD COLUMN nov_avg FLOAT,
ADD COLUMN dec_avg FLOAT,
ADD COLUMN jan_min FLOAT,
ADD COLUMN feb_min FLOAT,
ADD COLUMN mar_min FLOAT,
ADD COLUMN apr_min FLOAT,
ADD COLUMN may_min FLOAT,
ADD COLUMN jun_min FLOAT,
ADD COLUMN jul_min FLOAT,
ADD COLUMN aug_min FLOAT,
ADD COLUMN sep_min FLOAT,
ADD COLUMN oct_min FLOAT,
ADD COLUMN nov_min FLOAT,
ADD COLUMN dec_min FLOAT,
ADD COLUMN jan_max FLOAT,
ADD COLUMN feb_max FLOAT,
ADD COLUMN mar_max FLOAT,
ADD COLUMN apr_max FLOAT,
ADD COLUMN may_max FLOAT,
ADD COLUMN jun_max FLOAT,
ADD COLUMN jul_max FLOAT,
ADD COLUMN aug_max FLOAT,
ADD COLUMN sep_max FLOAT,
ADD COLUMN oct_max FLOAT,
ADD COLUMN nov_max FLOAT,
ADD COLUMN dec_max FLOAT;

ALTER TABLE actual.top_cultural_country
ADD COLUMN jan_avg FLOAT,
ADD COLUMN feb_avg FLOAT,
ADD COLUMN mar_avg FLOAT,
ADD COLUMN apr_avg FLOAT,
ADD COLUMN may_avg FLOAT,
ADD COLUMN jun_avg FLOAT,
ADD COLUMN jul_avg FLOAT,
ADD COLUMN aug_avg FLOAT,
ADD COLUMN sep_avg FLOAT,
ADD COLUMN oct_avg FLOAT,
ADD COLUMN nov_avg FLOAT,
ADD COLUMN dec_avg FLOAT,
ADD COLUMN jan_min FLOAT,
ADD COLUMN feb_min FLOAT,
ADD COLUMN mar_min FLOAT,
ADD COLUMN apr_min FLOAT,
ADD COLUMN may_min FLOAT,
ADD COLUMN jun_min FLOAT,
ADD COLUMN jul_min FLOAT,
ADD COLUMN aug_min FLOAT,
ADD COLUMN sep_min FLOAT,
ADD COLUMN oct_min FLOAT,
ADD COLUMN nov_min FLOAT,
ADD COLUMN dec_min FLOAT,
ADD COLUMN jan_max FLOAT,
ADD COLUMN feb_max FLOAT,
ADD COLUMN mar_max FLOAT,
ADD COLUMN apr_max FLOAT,
ADD COLUMN may_max FLOAT,
ADD COLUMN jun_max FLOAT,
ADD COLUMN jul_max FLOAT,
ADD COLUMN aug_max FLOAT,
ADD COLUMN sep_max FLOAT,
ADD COLUMN oct_max FLOAT,
ADD COLUMN nov_max FLOAT,
ADD COLUMN dec_max FLOAT;

ALTER TABLE actual.top_leisure_country
ADD COLUMN jan_avg FLOAT,
ADD COLUMN feb_avg FLOAT,
ADD COLUMN mar_avg FLOAT,
ADD COLUMN apr_avg FLOAT,
ADD COLUMN may_avg FLOAT,
ADD COLUMN jun_avg FLOAT,
ADD COLUMN jul_avg FLOAT,
ADD COLUMN aug_avg FLOAT,
ADD COLUMN sep_avg FLOAT,
ADD COLUMN oct_avg FLOAT,
ADD COLUMN nov_avg FLOAT,
ADD COLUMN dec_avg FLOAT,
ADD COLUMN jan_min FLOAT,
ADD COLUMN feb_min FLOAT,
ADD COLUMN mar_min FLOAT,
ADD COLUMN apr_min FLOAT,
ADD COLUMN may_min FLOAT,
ADD COLUMN jun_min FLOAT,
ADD COLUMN jul_min FLOAT,
ADD COLUMN aug_min FLOAT,
ADD COLUMN sep_min FLOAT,
ADD COLUMN oct_min FLOAT,
ADD COLUMN nov_min FLOAT,
ADD COLUMN dec_min FLOAT,
ADD COLUMN jan_max FLOAT,
ADD COLUMN feb_max FLOAT,
ADD COLUMN mar_max FLOAT,
ADD COLUMN apr_max FLOAT,
ADD COLUMN may_max FLOAT,
ADD COLUMN jun_max FLOAT,
ADD COLUMN jul_max FLOAT,
ADD COLUMN aug_max FLOAT,
ADD COLUMN sep_max FLOAT,
ADD COLUMN oct_max FLOAT,
ADD COLUMN nov_max FLOAT,
ADD COLUMN dec_max FLOAT;

-- adding to the tables 
UPDATE actual.top_leisure_country tn
SET 
  jan_avg = sub.jan_avg,
  feb_avg = sub.feb_avg,
  mar_avg = sub.mar_avg,
  apr_avg = sub.apr_avg,
  may_avg = sub.may_avg,
  jun_avg = sub.jun_avg,
  jul_avg = sub.jul_avg,
  aug_avg = sub.aug_avg,
  sep_avg = sub.sep_avg,
  oct_avg = sub.oct_avg,
  nov_avg = sub.nov_avg,
  dec_avg = sub.dec_avg,

  jan_min = sub.jan_min,
  feb_min = sub.feb_min,
  mar_min = sub.mar_min,
  apr_min = sub.apr_min,
  may_min = sub.may_min,
  jun_min = sub.jun_min,
  jul_min = sub.jul_min,
  aug_min = sub.aug_min,
  sep_min = sub.sep_min,
  oct_min = sub.oct_min,
  nov_min = sub.nov_min,
  dec_min = sub.dec_min,

  jan_max = sub.jan_max,
  feb_max = sub.feb_max,
  mar_max = sub.mar_max,
  apr_max = sub.apr_max,
  may_max = sub.may_max,
  jun_max = sub.jun_max,
  jul_max = sub.jul_max,
  aug_max = sub.aug_max,
  sep_max = sub.sep_max,
  oct_max = sub.oct_max,
  nov_max = sub.nov_max,
  dec_max = sub.dec_max
FROM (
  SELECT 
    country, 
    -- Averages
    AVG(january_avg) AS jan_avg, 
    AVG(february_avg) AS feb_avg,
    AVG(march_avg) AS mar_avg,
    AVG(april_avg) AS apr_avg,
    AVG(may_avg) AS may_avg,
    AVG(june_avg) AS jun_avg,
    AVG(july_avg) AS jul_avg,
    AVG(august_avg) AS aug_avg,
    AVG(september_avg) AS sep_avg,
    AVG(october_avg) AS oct_avg,
    AVG(november_avg) AS nov_avg,
    AVG(december_avg) AS dec_avg,
    
    -- Minimums
    MIN(january_min) AS jan_min,
    MIN(february_min) AS feb_min,
    MIN(march_min) AS mar_min,
    MIN(april_min) AS apr_min,
    MIN(may_min) AS may_min,
    MIN(june_min) AS jun_min,
    MIN(july_min) AS jul_min,
    MIN(august_min) AS aug_min,
    MIN(september_min) AS sep_min,
    MIN(october_min) AS oct_min,
    MIN(november_min) AS nov_min,
    MIN(december_min) AS dec_min,
    
    -- Maximums
    MAX(january_max) AS jan_max,
    MAX(february_max) AS feb_max,
    MAX(march_max) AS mar_max,
    MAX(april_max) AS apr_max,
    MAX(may_max) AS may_max,
    MAX(june_max) AS jun_max,
    MAX(july_max) AS jul_max,
    MAX(august_max) AS aug_max,
    MAX(september_max) AS sep_max,
    MAX(october_max) AS oct_max,
    MAX(november_max) AS nov_max,
    MAX(december_max) AS dec_max

  FROM actual.detailed_view dv 
  GROUP BY country
) sub
WHERE tn.country = sub.country;


select *
from actual.top_leisure_country tnc ;