

select COUNT(*)
from worldwide_travel_cities_dataset;


select 
	key::int as _month,
	(value ->> 'avg')::numeric as average,
	(value ->> 'max')::numeric as maximum,
	(value ->> 'min')::numeric as minimum
from worldwide_travel_cities_dataset, 
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


-- categorising into each type of travel destination 

-- nature_destination
create table actual.nature_destination as 
select *
from temporary_table_temperature_inc
where wellness > 2 and nature >2 and adventure > 2;

-- nature_destination
create table actual.cultural_destination as 
select *
from temporary_table_temperature_inc
where culture > 3 and cuisine >3 ;

-- nature_destination
create table actual.leisure_destination as 
select *
from temporary_table_temperature_inc
where urban > 3 and nightlife >3 ;

-- beaches did not get included in the consideration 




