/*
Title: Bixi Bikes Usage Analysis (data from 2016 and 2017)
Author: Fayo Ibitoye
Date: November 1st, 2022
*/

-- Set bixi schema as default
USE bixi;

-- Business Question:
-- The purpose of this analysis is to provide an overall understanding of how people use 
-- Bixi bikes. Based on this information, insights and recommendations to improve overall business growth will be provided. 

# Exploratory Data Analysis (EDA)

-- Get a better understanding of the datasets by looking into the tables
-- First off, the stations table


-- Get a better understanding of the datasets by looking into the tables
-- First off, the stations table
SELECT *
FROM stations;
-- This enables us to see the entire dataset. Now we'll check how many rows are in the stations table.

SELECT COUNT(*) AS num_of_stations
FROM stations;
# There are 540 stations in the dataset

-- Now we'll check how many trips are in the dataset.
SELECT COUNT(*) AS num_of_trips
FROM trips;
# There are 8,584,166 trips in the dataset


-- Next, we want to know the content of the trips table.
SELECT *
FROM trips;

# In order to analyze the dataset, we will need to gain an overall view of the volume of usage of Bixi Bikes and what factors influence it.

# We'll start the analysis by finding the total number of trips in each year - 2016-2017

#Total number of trips in 2016 
SELECT COUNT(*) AS num_of_trips_2016
FROM trips
WHERE YEAR(start_date)= 2016;

#There are 3,917,401 trips in 2016 

#Total number of trips in 2017
SELECT COUNT(*) AS num_of_trips_2017
FROM trips
WHERE YEAR(start_date)= 2017;

#There are 4666765 trips in 2017
-- From the result we see more trips were taken in 2017,almost a million more trips.

# Based on the total number of trips in 2016 and 2017, it was observed that more trips
# were taken in 2017. It would be interesting to see the months that had the most
# number of trips for each year. This could lead to potential recommendations on promotions 
# that could increase Bixi's revenue.


#Total number of trips in 2016 broken down by month
SELECT COUNT(*) AS num_of_trips_bymonth_2016, MONTH(start_date) AS Month
FROM trips
WHERE YEAR(start_date)= 2016
GROUP BY MONTH(start_date);

-- According to the results of the query, July has the highest record of trips in 2016. Although,
-- the summer months in general have the highest number of trips. This means that people 
-- use the Bixi bikes more in the summer months than any other time in the year, this could be 
-- due to warmer weather.

#Total number of trips in 2017 broken down by month
SELECT COUNT(*) AS num_of_trips_bymonth_2017, MONTH(start_date) AS Month
FROM trips
WHERE YEAR(start_date)= 2017
GROUP BY MONTH(start_date);
-- July has the highest number of trips in 2017 according to the dataset. 
-- We can assume that due to the July being the peak of summer, more people are willing to ride bikes due to favourable weather.

#Average number of trips a day for each year-month combination
SELECT     
    YEAR(start_date) AS 'Years',
    MONTH(start_date) AS 'Month',
	COUNT(*) /  COUNT(DISTINCT DAY (start_date))AS avg_trips_per_day
FROM trips
GROUP BY YEAR(start_date),MONTH(start_date)
ORDER BY YEAR(start_date),MONTH(start_date) ASC;
 -- July of 2016 & 2017 have the highest average number of trips based on the results of the query.

# This next part may not be essential to the analysis, but it is a way to show how to 
# create a new table with the results of the previous query.


-- First, I will drop the table if it exists to make sure not to overwrite any existing information, as this is good practice.
 
 DROP TABLE IF EXISTS working_table1;
 CREATE TABLE working_table1 
 SELECT     
    YEAR(start_date) AS 'Year',
    MONTH(start_date) AS 'Month',
  COUNT(*) /  COUNT(DISTINCT DAY (start_date)) AS avg_trips_per_day
    FROM trips 
 GROUP BY YEAR(start_date),MONTH(start_date)
 ORDER BY YEAR(start_date),MONTH(start_date) ASC;
 # We'll run this code to ensure the newtable and its contents are saved accurately.
 SELECT * 
 FROM working_table1;
 
-- For the next part of the analysis, I will be comparing the behaviour between members and non-members, 
-- To understand their behaviours and potentially provide business recommendations based on the observed insights.
 #Total number of trips in year 2017 by membership
SELECT COUNT(*) AS num_of_trips_bymonth_2017, is_member
FROM trips
WHERE YEAR(start_date)= 2017
GROUP BY is_member;

-- 3,784,682 trips were taken by members
-- 882,083 trips were taken by non-members

-- Unsurprisingly, the majority of trips were taken by members. 
-- Next, I will find out the percentage of trips by members to understand months with the highest and lowest percentages of trips taken by members.
 
#Percentage of Total trips by members for the year 2017 broken down monthly
SELECT AVG(is_member)*100, MONTH(start_date)
FROM trips
WHERE YEAR(start_date) = 2017
GROUP BY MONTH(start_date);


-- Interesting, based on the result of the previous query, the percentage for member trips reduces drastically in the summer months, and increases again in the fall/winter/spring months. 
-- This means that non-members are taking more trips in the summer than any other time of the year. 
-- This seems like a great opportunity to convert non-members to members since we know when they use the Bixi bikes the most.

#MONTHS WITH THE HIGHEST NUMBER OF TRIPS FOR MEMBERS
SELECT COUNT(*), MONTH(start_date), is_member
FROM trips
WHERE is_member = 1
GROUP BY MONTH(start_date)
ORDER BY COUNT(*)DESC;

#MONTHS WITH THE HIGHEST NUMBER OF TRIPS FOR NON-MEMBERS
SELECT COUNT(*), MONTH(start_date), is_member
FROM trips
WHERE is_member = 0
GROUP BY MONTH(start_date)
ORDER BY COUNT(*)DESC;

-- With this result I would offer discount's in the Month's of June, July and August for Non-members to convert to members because these months have the highest number of trips for Non-members and members.
-- An example of a type of discount, would be that if the non-member signs up to be a member, they would get 20% off the summer months. Another recommendation to improve overall business growth would be to promote the Bixi program to bring in new riders before the summer peaks.

# For the next part of the analysis, I will be retrieving insights regarding the stations where trips are taken.

#NAMES OF THE 5 MOST POPULAR STARTING STATIONS? DETERMINE ANSWER WITHOUT SUBQUERY
SELECT trips.start_station_code AS Trips_Ssc, COUNT(*) AS Number_of_visits, stations.name As Five_Most_Popular_Stations
FROM trips
JOIN stations ON trips.start_station_code = stations.code 
GROUP BY trips.start_station_code, stations.name
ORDER BY COUNT(*) DESC
LIMIT 5;
-- This query took a while to run, I will construct a subquery to make the query more efficient and less computationally intensive.

-- Let's start with writing the subquery first.

SELECT start_station_code, COUNT(*) AS number_of_trips
FROM trips
GROUP BY start_station_code
ORDER BY number_of_trips DESC
LIMIT 5;

#Now we write the full query
SELECT Sub.number_of_trips, stations.name
FROM 
(SELECT start_station_code, COUNT(*) AS number_of_trips
FROM trips
GROUP BY start_station_code
ORDER BY number_of_trips DESC
LIMIT 5
) Sub
JOIN stations ON start_station_code = stations.code;

-- From both results, we see the Top 5 most popular starting stations, with Mackay/de Maisonneuve being the most popular station. 
-- Also, the subquery provided the same results with over half the time as the one without the subquery.
  

# Now that we know the most popular station, it would be interesting to see how Bixi users start and end at the station throughout the day. I will be doing that with CASE WHEN statements. 
#How is the number of starts and ends distributed for the station Mackay/ de Maisonneuve throughout the day?
SELECT COUNT(*),
CASE
	WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
	WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
	WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
	ELSE "night"
END AS time_of_day
FROM trips
WHERE start_station_code = 6100
GROUP BY time_of_day;


SELECT COUNT(*),
CASE
	WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
	WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
	WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
	ELSE "night"
END AS time_of_day
FROM trips
WHERE end_station_code = 6100
GROUP BY time_of_day;
-- I observed that the highest number of trips are taken in the evening and afternoon for both the start and end station. 
-- This can indicate that a lot more people are able to ride bikes during these times because they are done with the day's activities such as work, school,etc.,


# Let's now look at the factors that influence how Bixi users utilize the stations. 
-- First, we will count the number of starting trips per station
SELECT start_station_code AS station_code, COUNT(start_station_code) AS number_trips
FROM trips
GROUP BY station_code
ORDER BY number_trips DESC;

#-- Now we will Count the number of round trips for each station.
SELECT start_station_code AS station_code, COUNT(start_station_code) AS number_of_round_trips
FROM trips
WHERE start_station_code = end_station_code
GROUP BY start_station_code
ORDER BY number_of_round_trips DESC;

-- Our next step is to combine the previous queries and calculate the fraction round trips to the total number of strating trips for each station.
SELECT stations.name, 
SUM(IF(start_station_code = end_station_code, 1,0)) /COUNT(*) AS round_trip_fraction
FROM trips
JOIN stations ON  stations.code = start_station_code 
GROUP BY stations.name
ORDER BY round_trip_fraction DESC;


-- Now we filter down to stations with at least 500 trips originationg from them and having at least 10% of their trips as round trips.
SELECT stations.name,
SUM(IF(start_station_code = end_station_code, 1,0))/COUNT(*) AS round_trip_fraction
FROM trips
JOIN stations ON  stations.code = start_station_code
GROUP BY stations.name
HAVING round_trip_fraction >= 0.1 AND COUNT(start_station_code) >= 500
ORDER BY round_trip_fraction DESC;
-- These stations are the busiest according to the results. This is due to them having at least 500 trips originationg from them and 10% of their trips as round trips.
-- We will filter down to the Top 5 stations.

SELECT stations.name,
SUM(IF(start_station_code = end_station_code, 1,0))/COUNT(*) AS round_trip_fraction
FROM trips
JOIN stations ON  stations.code = start_station_code
GROUP BY stations.name
HAVING round_trip_fraction >= 0.1 AND COUNT(start_station_code) >= 500
ORDER BY round_trip_fraction DESC
LIMIT 5;
-- These stations have the highest number of round trip fractions and it could be for various reasons such as:
-- The population and popularity of the cities, the location of the stations in the city. E.g if a station is located downtown,
-- there's a probability that there will be a lot more customers patronizing the bixi bikes. 
-- This can be because of easy accessibility after work for employed people. Also the location might be central to other locations in the city.

-- We would recommend that bixi invest more resources into these top 5 stations. 
-- They should run promos and give discounts to convert Non-members to members as they have the highest number of round trips.


