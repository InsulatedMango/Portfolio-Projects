--2/13/2023
--Caleb
--Source: https://www.kaggle.com/datasets/sidtwr/videogames-sales-dataset
--Unguided project
--Goal: Explore the dataset and see what I can find

--Notes
--This data is not current or up to date and is only meant to be an exercise in SQL


--Looking at dataset as a whole to get a feel for what is in it
SELECT *
FROM PortfolioProject..video_game$


--Checking for genre
--Action games have the highest count while puzzle games come in last
SELECT Genre AS genres, COUNT(Genre) AS total
FROM PortfolioProject..video_game$
GROUP BY Genre
ORDER BY total


--Seeing who published the most games
--Electronic Arts released the most at 1356
SELECT Publisher AS Publisher, COUNT(Publisher) AS Total
FROM PortfolioProject..video_game$
GROUP BY Publisher
ORDER BY total DESC

--Checking Valve
--This list is missing a lot of valve games
SELECT *
FROM PortfolioProject..video_game$
WHERE Publisher like '%valve%'


--Checking out platform
--The PS2 and DS have the most releases
--The PS3, Wii, and Xbox360 all have very close numbers
SELECT Platform AS platform, COUNT(Platform) AS total
FROM PortfolioProject..video_game$
GROUP BY Platform
ORDER BY total DESC


--I want to see more from Activision
SELECT *
FROM PortfolioProject..video_game$
WHERE Publisher like '%Activision%' and Name like '%call of duty%'
ORDER BY Global_players DESC

--I want to know what the most popular call of duty is
--It appears that Modern Warfare 3 was the most popular in this dataset
SELECT Name, Year_of_release, SUM(Global_players) as Total_global_players, Genre, Developer, Publisher
FROM PortfolioProject..video_game$
WHERE Publisher like '%Activision%' and Name like '%call of duty%'
GROUP BY Name, Year_of_release, Genre, Developer, Publisher
ORDER BY Total_global_players DESC

--It is important to keep in mind this dataset could be wrong as these companies do not like to reveal this data
--A good thing to do would be to scrape the data from Steam Charts for call of duty to get a look at peek PC numbers. this would also update it for games not in this list. Perhaps I will learn scraping and do this again with steam. 


--Now I want to have a look around nintendo

--Wii sports is the top according to this list. Nice. 
SELECT *
FROM PortfolioProject..video_game$
WHERE Publisher like '%nintendo%'
ORDER BY Global_players DESC

--I like Zelda games so let's look at Zelda
--This query really shows the age of this as it is missing the newest zelda game
--there is no nintendo switch information
--It says ocarina of time outsold twilight princess, I have heard from other sources that is false unless including remakes. Something to keep in mind
SELECT *
FROM PortfolioProject..video_game$
WHERE Publisher like '%nintendo%' and Name like '%zelda%'
ORDER BY Global_players DESC

-- let's group games together ignoring platform
--this doesnt combine the original games and the newer remakes
SELECT Name, Year_of_release, SUM(Global_players) AS Total_global_players, Genre, Developer, Publisher
FROM PortfolioProject..video_game$
WHERE Publisher like '%nintendo%' and Name like '%zelda%'
GROUP BY Name, Year_of_release, Genre, Developer, Publisher
ORDER BY Total_global_players DESC

--this query now bundles the original games (OG) and the remakes.
--when you include remakes Ocarina of Time beats all the others
SELECT REPLACE(REPLACE(Name, 'HD', ''), '3D', '') AS Merged_Games, SUM(Global_players) AS Total_global_players, Genre, Publisher
FROM PortfolioProject..video_game$
WHERE Publisher like '%nintendo%' and Name like '%zelda%'
GROUP BY REPLACE(REPLACE(Name, 'HD', ''), '3D', ''), Genre, Publisher
ORDER BY Total_global_players DESC


--Let's have a look around Electronic Arts

--A quick overview shows that Fifa 16 is the most popular
SELECT *
FROM PortfolioProject..video_game$
WHERE Publisher like '%electronic arts%'
ORDER BY Global_players DESC

--I want to see what their most popular genre is
--Action is the most popular Genre
SELECT Genre, SUM(Global_players) AS Players
FROM PortfolioProject..video_game$
GROUP BY Genre
ORDER BY Players DESC

--I want to see what the most popular shooter games are
--as I suspected Battlefield 3 is at the top
SELECT Name, Genre, SUM(Global_players) AS Players
FROM PortfolioProject..video_game$
WHERE Genre like '%shooter%' and Publisher like '%electronic arts%'
GROUP BY Name, Genre
ORDER BY Players DESC

--I want to do the same for action games
--The most popular action game is actually a sports game. I will do this again but include sports in the list.
SELECT Name, Genre, Year_of_release, SUM(Global_players) AS Players
FROM PortfolioProject..video_game$
WHERE Genre like '%action%' and Publisher like '%electronic arts%'
GROUP BY Name, Genre, Year_of_release
ORDER BY Players DESC

--lets do it again
--doing this we can see that we now have all the fifa games
SELECT Name, Genre, Year_of_release, SUM(Global_players) AS Players
FROM PortfolioProject..video_game$
WHERE Publisher like '%electronic arts%' and (Genre like '%action%' OR Genre like '%sports%')
GROUP BY Name, Genre, Year_of_release
ORDER BY Players DESC

--At this point I have seen everything I want from this dataset. While it is out of date, it was fun to explore.