
-- Merge Tables 

DROP table if exists merged_table; 
CREATE TABLE merged_table
SELECT * FROM 
(SELECT 
camp.name as Campaign_name,
x.category, 
x.sub_category, 
country.name AS country, 
currency.name AS currency, 
-- Formatting Dates 
-- STR_TO_DATE(string, "%Y/%M/%D") string to date
STR_TO_DATE(DATE_FORMAT(camp.launched, "%Y/%M/%D"), "%Y/%M/%D")  AS launched,
STR_TO_DATE(DATE_FORMAT(camp.deadline, "%Y/%M/%D"), "%Y/%M/%D")  AS Deadline,
-- Length of campaign 
 DATEDIFF(Deadline, launched ) AS Days_length, 
camp.goal, 
camp.pledged, 
camp.backers,
camp.outcome
FROM 
    (SELECT sc.id AS Sub_Category_id, 
     sc.category_id, 
	c.name AS Category,
    sc.name AS Sub_Category 
     FROM sub_category sc 
     JOIN category c 
     ON sc.category_id=c.id) AS X
JOIN campaign camp 
ON x.Sub_Category_id =camp.sub_category_id
JOIN country 
ON camp.country_id=country.id 
JOIN currency 
ON camp.currency_id=currency.id) as T ; 
select * from merged_table;



-- check how many categories and the number of records for each category
SElect 
m.category, 
COUNT(m.category) AS Count
from merged_table AS m
GROUP BY m.category 
ORDER by Count DESC; 

-- Games' category is the 4th most popular Category with 1343 records 

-- Look for board games sybcategory and number of records 
Select
m.category,
m.Sub_Category, 
COUNT(m.Sub_category) AS Count
from merged_table AS m 
Where m.Category="Games"
GROUP BY m.Sub_category 
ORDER by Count DESC; 

-- Tabletop Games, Playing Cards and Puzzles are the subcategories of interest but what about games? 
-- check Games subcategory titles 
Select
*
from merged_table AS m 
Where m.Sub_Category="Games";

-- we see that many campaigns' titles contain the word cards, we re going to filter out games not related to board games 
Select
*
from merged_table AS m 
Where m.Sub_Category="Games" and m.name like ("%card%") ; 
-- we see that these games where either cancelled or failed so we will not consider them in this study 

-- now Let's crate a table selecting only the subcategory of board games 

DROP table if exists board_games;
CREATE table Board_Games 
SELECT * FROM 
(Select * 
from merged_table AS m 
Where m.Sub_Category in ("Tabletop Games", "Playing Cards", "Puzzles")) as b; 
 
select * from Board_Games; 


-- check the average goal and Avg backers for successful campaigns 
select 
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers 
from Board_Games Bg 
where outcome="successful" and currency="USD" and goal between 10000 and 15000  and pledged < goal*2 
Group by Bg.outcome;

-- Avg_goal=12200 and Avg_Pledged=15700 & Avg backers=300 


-- Determine Avg goal for successful campaigns where avg-pledged is above 15000 USD 
select 
outcome,
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers 
from Board_Games Bg 
where currency="USD" and  pledged between 15000 and 20000 
Group by outcome;

select 
outcome,
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers 
from Board_Games Bg 
where pledged between 15000 and 18000
Group by outcome;




-- determine success rate for each goal range 
select 
Goal_Range, 
Round(Avg_goal) as Avg_goal, 
Round(Avg_pledged) as Avg_pledged, 
Round(Avg_backers) as Avg_backers, 
total_successful, 
total_Not_Successful,
 x.total_successful/(x.total_successful + x.total_Not_Successful) AS success_rate 
 from 
(select 
*
 from
(select 
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers,
count(*) as total_successful,
(case when goal between 8000 and 9999 then '[8000-10000[' 
      when goal between 10000 and 11999 then '[10000-12000['
      when goal between 12000 and 13999 then '[12000-14000['
      when goal between 14000 and 15000 then '[14000-15000]'
      else 'outside the range' 
      end) as Goal_Range
from Board_Games Bg 
where outcome="successful" and currency="USD"
Group by Goal_Range) as s 
JOIN 
(select 
count(*) as total_Not_Successful,
(case when goal between 8000 and 9999 then '[8000-10000[' 
      when goal between 10000 and 11999 then '[1000-12000['
      when goal between 12000 and 13999 then '[12000-14000['
      when goal between 14000 and 15000 then '[14000-15000]'
      else 'outside the range' 
      end) as Goal_Range2
from Board_Games Bg 
where outcome <> "successful" and currency="USD"
Group by Goal_Range2 
) as NS 
ON NS.Goal_Range2=s.Goal_Range) as x 
order by success_rate  DESC; 
-- the goal range of [8000,10000] has 59 % chance  

-- Further analyses determine success rate in the [8000, 10000] Interval
select 
Goal_Range, 
Round(Avg_goal) as Avg_goal, 
Round(Avg_pledged) as Avg_pledged, 
Round(Avg_backers) as Avg_backers, 
total_successful, 
total_Not_Successful,
 x.total_successful/(x.total_successful + x.total_Not_Successful) AS success_rate
 from 
(select 
*
 from
(select 
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers,
count(*) as total_successful,
(case when goal between 8000 and 8499 then '[8000-8500[' 
      when goal between 8500 and 8999 then '[8500-9000['
      when goal between 9000 and 9499 then '[9000-9500['
      when goal between 9500 and 10000 then '[9500-10000]'
      else 'outside the range' 
      end) as Goal_Range
from Board_Games Bg 
where outcome="successful" and currency="USD"
Group by Goal_Range) as s 
JOIN 
(select 
count(*) as total_Not_Successful,
(case when goal between 8000 and 8499 then '[8000-8500[' 
      when goal between 8500 and 8999 then '[8500-9000['
      when goal between 9000 and 9499 then '[9000-9500['
      when goal between 9500 and 10000 then '[9500-10000]'
      else 'outside the range' 
      end) as Goal_Range2
from Board_Games Bg 
where outcome <> "successful" and currency="USD"
Group by Goal_Range2 
) as NS 
ON NS.Goal_Range2=s.Goal_Range) as x 
order by success_rate DESC; 
-- the goal range of [9000,9500] has 80% chance success rate

-- Further analyses determine success rate in [9000, 9500] interval
select *, 
 x.total_successful/(x.total_successful + x.total_Not_Successful) AS success_rate
 from 
(select 
*
 from
(select 
Avg(goal) as Avg_goal, 
AVG(pledged) as Avg_pledged,
Avg(backers) as Avg_backers,
count(*) as total_successful,
(case when goal between 9000 and 9199 then '[9000-9200[' 
      when goal between 9200 and 9299 then '[9200-9300['
      when goal between 9300 and 9399 then '[9300-9400['
      when goal between 9400 and 9500 then '[9400-9500]'
      else 'outside the range' 
      end) as Goal_Range
from Board_Games Bg 
where outcome="successful" and currency="USD"
Group by Goal_Range) as s 
JOIN 
(select 
count(*) as total_Not_Successful,
(case when goal between 9000 and 9199 then '[9000-9200[' 
      when goal between 9200 and 9299 then '[9200-9300['
      when goal between 9300 and 9399 then '[9300-9400['
      when goal between 9400 and 9500 then '[9400-9500]'
      else 'outside the range' 
      end) as Goal_Range2
from Board_Games Bg 
where outcome <> "successful" and currency="USD"
Group by Goal_Range2 
) as NS 
ON NS.Goal_Range2=s.Goal_Range) as x 
order by success_rate DESC; 
-- the goal range of [9000,9200] has 80% chance success rate

select *, 
Avg(pledged/backers) as Avg_pledge_per_backer 
from board_games 
where goal between 8000 and 10000 and outcome="successful" and currency="USD"
group by outcome; 

-- minimum number or backers to achieve 15000 USD 
select 
15000/66 as Min_Num_Backers; 
-- 227 backers 

-- Determine which subcategory in board games is more successful 
SELECT 
sub_category,
Round(sum(pledged)) 
 FROM brainstation.board_games 
group by sub_category
order by sum(pledged)  desc;

-- let's analyze the success rate of tabletop games over time 
select 
x.Year,
Avg_goal, 
Avg_pledged, 
Avg_backers, 
total_successful, 
total_Not_Successful,
x.total_successful/(x.total_successful + x.total_Not_Successful) AS success_rate 
 from 
(select 
*
 from
(select 
Year(launched) as Year,
Round(Avg(goal)) as Avg_goal, 
Round(Avg(pledged)) as Avg_pledged, 
Round(Avg(backers)) as Avg_backers, 
count(*) as total_successful
from Board_Games Bg 
where outcome="successful" and currency="USD"
Group by Year) as s 
JOIN 
  (select 
  Year(launched) as Year2,
   count(*) as total_Not_Successful
    from Board_Games Bg 
    where outcome <> "successful" and currency="USD"
    Group by Year2
   ) as NS 
ON NS.Year2=s.Year) as x 
order by success_rate  DESC; 

select 
*
 from
(select 
Round(Avg_goal) as Avg_goal, 
Round(Avg_pledged) as Avg_pledged, 
Round(Avg_backers) as Avg_backers,
Year(launched) as Year,
count(*) as total_successful
from Board_Games Bg 
where outcome="successful" and currency="USD"
Group by Year) as s 
JOIN 
  (select 
  Year(launched) as Year2,
   count(*) as total_Not_Successful
    from Board_Games Bg 
    where outcome <> "successful" and currency="USD"
    Group by Year2
   ) as NS 
ON NS.Year2=s.Year;
