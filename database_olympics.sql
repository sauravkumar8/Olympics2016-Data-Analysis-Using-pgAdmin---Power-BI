DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         int,
    height      int,
    weight      decimal,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

--import data from csv filess
--view data extracted from dataset

--Identify the sport which was played in all summer olympics.
with t1 as
	(select count(distinct games) as total_summer_games from OLYMPICS_HISTORY
	where season='Summer'),
t2 as 
	(select distinct(sport), games from OLYMPICS_HISTORY where season='Summer' order by games),
t3 as
	(select sport, count(games) as no_of_games
	 from t2 group by sport)
	
select * 
from t3
join t1 on t1.total_summer_games = t3.no_of_games ;

-- Fetch the top 5 athletes who have won the most gold medals.
with t1 as
	(select name, count(1) as total_medals from OLYMPICS_HISTORY 
	where medal = 'Gold' group by name
	order by count(1) desc),
t2 as
	(select *, dense_rank() over(order by total_medals desc)as rank from t1)
	
select * from t2 where rank<=5;

--List down total gold, silver and broze medals won by each country.

--subquery for crosstab 
select d.region as country, medal, count(1) as total_medal
	from OLYMPICS_HISTORY B
	join OLYMPICS_HISTORY_NOC_REGIONS D on b.noc=d.noc
	where medal <> 'NA'
	group by country,medal
	order by country,medal

select country,
	coalesce(gold,0) as GOLD,
	coalesce(silver,0) as SILVER,
	coalesce(bronze,0) as BRONZE
	from crosstab('select d.region as country, medal, count(1) as total_medal
	from OLYMPICS_HISTORY B
	join OLYMPICS_HISTORY_NOC_REGIONS D on b.noc=d.noc
	where medal <> ''NA''
	group by country,medal
	order by country,medal',
	'values(''Bronze''),(''Gold''),(''Silver'')')
	as result(country varchar, bronze bigint, gold bigint, silver bigint)
	order by gold desc, silver desc, bronze desc

-- created and enables extension tablefunc

--Identify which country won the most gold, most silver and most bronze medals in each olympic games.

    WITH temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    	 , substring(games, position(' - ' in games) + 3) as country
         , coalesce(gold, 0) as gold
         , coalesce(silver, 0) as silver
         , coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    				  	, count(1) as total_medals
    				  FROM olympics_history oh
    				  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint))
    select distinct games
    	, concat(first_value(country) over(partition by games order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by games order by gold desc)) as Max_Gold
    	, concat(first_value(country) over(partition by games order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by games order by silver desc)) as Max_Silver
    	, concat(first_value(country) over(partition by games order by bronze desc)
    			, ' - '
    			, first_value(bronze) over(partition by games order by bronze desc)) as Max_Bronze
    from temp
    order by games;

--How many olympics games have been held?
select count(distinct games) as TOTAL_OLYMPIC_GAMES 
from olympics_history

--List down all Olympics games held so far.
select distinct year, season, city 
from olympics_history
order by year

-- Mention the total no of nations who participated in each olympics game?

with t1 as
(select games, d.region as country
	from OLYMPICS_HISTORY B
	join OLYMPICS_HISTORY_NOC_REGIONS D on b.noc=d.noc
	group by games,country)
select games, count(1) from t1
group by games
order by games desc

-- Which year saw the highest and lowest no of countries participating in olympics

with t1 as
(select games, d.region as country
	from OLYMPICS_HISTORY B
	join OLYMPICS_HISTORY_NOC_REGIONS D on b.noc=d.noc
	group by games,country),
t2 as
(	select games, count(1) as total_countries
	from t1
	group by games)

	select distinct
	concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from t2
      order by 1;
	  
-- Which nation has participated in all of the olympic games
with t1 as
(select count(distinct games) as no_of_games
 from olympics_history),
t2 as
 ( select games, d.region as country
	from OLYMPICS_HISTORY B
	join OLYMPICS_HISTORY_NOC_REGIONS D on b.noc=d.noc
 	group by games, d.region),
t3 as
	(select country, count(1) as total_participated_events
	 from t2 group by country)
select country,total_participated_events
from t3 
join t1 on t1.no_of_games = t3.total_participated_events 
order by country;
 
-- Fetch the top 5 athletes who have won the most gold medals.
with t1 as
	(select name, count(1) as total_medals from OLYMPICS_HISTORY 
	where medal = 'Gold' group by name
	order by count(1) desc),
t2 as
	(select *, dense_rank() over(order by total_medals desc)as rank from t1)
	
select * from t2 where rank<=5;

-- Which Sports were just played only once in the olympics.
with t1 as
(select distinct games, sport
from olympics_history),
t2 as
(select sport, count(1) as no_of_games
	from t1
    group by sport)
select t2.*, t1.games
from t2
join t1 on t1.sport = t2.sport
where t2.no_of_games = 1
order by t1.sport;


--Fetch the total no of sports played in each olympic games.
with t1 as
(select distinct games, sport
from olympics_history),
t2 as
(select games, count(1) as no_of_games
	from t1
    group by games)
select * from t2
order by games

--Fetch oldest athletes to win a gold medal
with temp as
            (select name,sex,age
              ,team,games,city,sport, event, medal
            from olympics_history where medal='Gold'),
        ranking as
            (select *, dense_rank() over(order by age desc) as rnk
           	from temp
            where medal='Gold')
-- to eliminate null values, rank selected as greater than 1
    select *
    from ranking
    where rnk > 1
	order by rnk;
	

--Find the Ratio of male and female athletes participated in all olympic games.

with t1 as
(select distinct(count(sex))as q1 from olympics_history where sex='F'),
t2 as
(select distinct(count(sex))as q2 from olympics_history where sex='M'),
t3 as
(select concat('1 : ', round(q2::decimal/q1,3)) as Ratio_F_M from t1,t2)
select * from t3

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with t1 as
	(select name, team, count(1) as total_medals from OLYMPICS_HISTORY 
	where medal in ('Gold','Bronze','Silver') group by name,team
	order by count(1) desc),
t2 as
	(select *, dense_rank() over(order by total_medals desc)as rank from t1)
	
select * from t2 where rank<=5;

-- Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select nr.region, count(1) as total_medals
            from olympics_history oh
            join olympics_history_noc_regions nr on nr.noc = oh.noc
            where medal <> 'NA'
            group by nr.region
            order by total_medals desc
			limit 5
--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
    FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
                , medal
                , count(1) as total_medals
                FROM olympics_history oh
                JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
                where medal <> ''NA''
                GROUP BY games,nr.region,medal
                order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)

--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

  with temp as
    	(SELECT substring(games, 1, position(' - ' in games) - 1) as games
    		, substring(games, position(' - ' in games) + 3) as country
    		, coalesce(gold, 0) as gold
    		, coalesce(silver, 0) as silver
    		, coalesce(bronze, 0) as bronze
    	FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games
    					, medal
    					, count(1) as total_medals
    				  FROM olympics_history oh
    				  JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    				  where medal <> ''NA''
    				  GROUP BY games,nr.region,medal
    				  order BY games,medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
    			   AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)),
    	tot_medals as
    		(SELECT games, nr.region as country, count(1) as total_medals
    		FROM olympics_history oh
    		JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
    		where medal <> 'NA'
    		GROUP BY games,nr.region order BY 1, 2)
    select distinct t.games
    	, concat(first_value(t.country) over(partition by t.games order by gold desc)
    			, ' - '
    			, first_value(t.gold) over(partition by t.games order by gold desc)) as Max_Gold
    	, concat(first_value(t.country) over(partition by t.games order by silver desc)
    			, ' - '
    			, first_value(t.silver) over(partition by t.games order by silver desc)) as Max_Silver
    	, concat(first_value(t.country) over(partition by t.games order by bronze desc)
    			, ' - '
    			, first_value(t.bronze) over(partition by t.games order by bronze desc)) as Max_Bronze
    	, concat(first_value(tm.country) over (partition by tm.games order by total_medals desc nulls last)
    			, ' - '
    			, first_value(tm.total_medals) over(partition by tm.games order by total_medals desc nulls last)) as Max_Medals
    from temp t
    join tot_medals tm on tm.games = t.games and tm.country = t.country
    order by games;

--Which countries have never won gold medal but have won silver/bronze medals?
 select * from (
    	SELECT country, coalesce(gold,0) as gold, coalesce(silver,0) as silver, coalesce(bronze,0) as bronze
    		FROM CROSSTAB('SELECT nr.region as country
    					, medal, count(1) as total_medals
    					FROM OLYMPICS_HISTORY oh
    					JOIN OLYMPICS_HISTORY_NOC_REGIONS nr ON nr.noc=oh.noc
    					where medal <> ''NA''
    					GROUP BY nr.region,medal order BY nr.region,medal',
                    'values (''Bronze''), (''Gold''), (''Silver'')')
    		AS FINAL_RESULT(country varchar,
    		bronze bigint, gold bigint, silver bigint)) x
    where gold = 0 and (silver > 0 or bronze > 0)
    order by gold desc nulls last, silver desc nulls last, bronze desc nulls last;

--In which Sport/event, India has won highest medals.
select sport, count(1) as total_medals
from olympics_history
where team = 'India'
and medal <> 'NA'
group by sport
order by total_medals desc
limit 1

--Break down all olympic games where india won medal for Hockey and how many medals in each olympic games
select team, sport, games, count(1) as total_medals
    from olympics_history
    where medal <> 'NA'
    and team = 'India' and sport = 'Hockey'
    group by team, sport, games
	order by games;


select * from olympics_history where team='Afghanistan' and medal <> 'NA'
select * from OLYMPICS_HISTORY_NOC_REGIONS;

