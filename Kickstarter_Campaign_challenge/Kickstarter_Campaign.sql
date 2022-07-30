
-- Merging Tables 
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


-- checking how many categories we have and the number of records for each category
SElect 
m.category, 
COUNT(m.category) AS Number_of_Campaigns
from merged_table AS m
GROUP BY m.category 
ORDER by Number_of_Campaigns DESC; 

-- Games' category is the 4th most popular Category with 1343 records 

-- searching for board games sybcategory and number of records 
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

-- creating a table selecting only the subcategory of boardgames 
DROP table if exists board_games;
CREATE table Board_Games 
SELECT * FROM 
(Select * 
from merged_table AS m 
Where m.Sub_Category in ("Tabletop Games", "Playing Cards", "Puzzles")) as b; 
 
select * from Board_Games; 

-- Analysis on Currencies 
select count(*) from brainstation.merged_table; 
-- 15000 
SELECT currency, 
count(currency) as Count,
count(currency)/15000 as pecentage
FROM brainstation.merged_table
group by currency ;
/* we notice that we have 13 currencies in our dataset, before doing any aggregations we should either convert all amounts from all currencies to USD or 
 judge that 11772 records in USD (78% of all records) is sufficient to conduct our analyses.
 In this study we will just filter out the other currencies */ 

-- Question1.	Are the goals for dollars raised significantly different between campaigns that are successful and unsuccessful?
Select 
outcome, 
ROUND(AVG(goal)) AS Avg_Goal
from merged_table AS m
where currency="USD"
GROUP BY outcome; 

--  the goals between successful and unsecsessful campaigns (either failed or canceled ) shows a significant difference, the average failed campaigns goals are ten times higher than the average successful goals

-- Checking successful and unsuccessful goals for board games 
Select 
outcome, 
ROUND(AVG(goal)) AS Avg_Goal
from board_games
where currency="USD"
GROUP BY outcome; 

-- Question 2.	What are the top/bottom 3 categories with the most backers? 
-- What are the top/bottom 3 subcategories by backers?

-- Top 3 categories with the most backers 
SElect 
m.category, 
sum(backers) AS Total_Backers
from merged_table AS m
GROUP BY m.category 
ORDER by Total_Backers DESC; 

-- Games	411671
-- Technology	329751
-- Design	262245

-- Bottom 3 categories with the least backers 
SElect 
m.category, 
sum(backers) AS Total_Backers
from merged_table AS m
GROUP BY m.category 
ORDER by Total_Backers; 

-- Dance	6022
-- Journalism	6206
-- Crafts	10418

-- Top 3 Subcategories with the most backers 
SElect 
m.Sub_Category, 
sum(backers) AS Total_Backers
from merged_table AS m
GROUP BY m.sub_category 
ORDER by Total_Backers DESC;

-- the best three sub-categoies are Tabletop Games with a total 247120 backers, Product Design with 221931 backers and Video Games with	141052 backers

-- Bottom 3 categories with the least backers 
SElect 
m.Sub_Category, 
sum(backers) AS Total_Backers
from merged_table AS m
GROUP BY m.sub_category 
ORDER by Total_Backers;
 
-- the bottom sub-categories are glass with only 2 bckers, Photo with 12 backers and Latin with 13 backers.alter

-- Question3.	What are the top/bottom 3 categories that have raised the most money? What are the top/bottom 3 subcategories that have raised the most money?

-- Top 3 categories with the most money : 
SElect 
m.category, 
Round(sum(pledged)) AS Total_Money
from merged_table AS m
where currency="USD" and outcome="successful"
GROUP BY m.category 
ORDER by Total_Money DESC; 

-- Games with 20.6 Million USD, Tachnology with 20.1 Million USD and design with 17.5 Million USD 

-- Bottom 3 categories with the least money 
SElect 
m.category, 
Round(sum(pledged)) AS Total_Money
from merged_table AS m
where currency="USD" and outcome="successful"
GROUP BY m.category 
ORDER by Total_Money ; 

-- Journalism with 0.4 Million USD, Dance with 0.4 Million USD and crafts with 0.43 Million USD 


-- Top 3 sub-categories with the most money 
SElect 
m.sub_category, 
Round(sum(pledged)) AS Total_Money
from merged_table AS m
where currency="USD" and outcome="successful"
GROUP BY m.sub_category 
ORDER by Total_Money DESC; 

-- Product design with 15.4 Million USD, Tabletop games with 15.1 Million USD and Web with 5.7 Million USD 

-- Bottom 3 sub_categories with the least money 
SElect 
m.sub_category, 
Round(sum(pledged)) AS Total_Money
from merged_table AS m
where currency="USD" and outcome="successful"
GROUP BY m.sub_category 
ORDER by Total_Money ; 

-- Embroidery, Textiles and family 

-- Question 4.	What was the amount the most successful board game campaign raised? 
-- How many backers did they have?

SElect 
*
from merged_table AS m
where currency="USD" and Sub_Category="Tabletop games" and outcome="successful"
ORDER by pledged DESC;
-- Gloomhaven (Second Printing) is th most successful Tabletop games campaign which raised around 4 Million USD with  40642 backers (their goal was just 100K USD) 

-- Question 5.	Rank the top three countries with the most successful campaigns in terms of dollars (total amount pledged), and in terms of the number of campaigns backed.
SElect 
*, 
Round(SUM(pledged)) As total_amount_pledged
from merged_table AS m
where  outcome="successful"
Group by country 
ORDER by total_amount_pledged DESC;

/* the top three countries with the most successful campaigns in terms of dollars (total amount pledged) are:
USA, united kingdom and canada with 100 Million USD , 8 Million USD and 1.8 Million USD respectively */

SElect 
country, 
Count(Campaign_name) As total_Campaigns_Backed
from merged_table AS m
where  outcome="successful"
Group by country 
ORDER by total_Campaigns_Backed DESC;

/* the top three countries with the most numbers of campaigns backed are:
 USA, united kingdom and Canada with 4365 , 487 and 137 backed campaigns respectively */
 
 -- Determine For Boardgames: the top three countries with the most successful campaigns in terms of dollars (total amount pledged), and in terms of the number of campaigns backed.
 SElect 
*, 
Round(SUM(pledged)) As total_amount_pledged
from board_games 
where  outcome="successful"
Group by country 
ORDER by total_amount_pledged DESC;
-- USA, united kingdom and germany with 15.5 Million USD , 1.9 Million GBP and 0.32 Million EUR respectively

SElect 
country, 
Count(Campaign_name) As total_Campaigns_Backed
from board_games AS m
where  outcome="successful"
Group by country 
ORDER by total_Campaigns_Backed DESC; 
-- USA, united kingdom and Canada with 249, 41 and 5 backed campaigns respectively

-- Question 6.	Do longer, or shorter campaigns tend to raise more money? Why?

-- For all campaigns 
SElect 
Days_length, 
Count(Campaign_name) As total_Campaigns_Backed
from merged_table
where  outcome="successful"
Group by Days_length
ORDER by total_Campaigns_Backed DESC; 
-- 30 is the optimal campaign length

-- For boardGames 
SElect 
Days_length, 
Count(Campaign_name) As total_Campaigns_Backed
from board_games
where  outcome="successful"
Group by Days_length
ORDER by total_Campaigns_Backed DESC; 
-- 30 is the optimal campaign length 

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
-- the goal range of [8000,10000] has 59 % success rate 

-- Further analyses: determine success rate in the [8000, 10000] Interval
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

-- let's analyze the success rate of boardgames over time 
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

-- Tables created in this work were exported to tableau for visualization. 