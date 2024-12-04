create database if not exists playstore;
select * from playstoreimpure;
select * from playstore;
truncate table playstore;
select * from playstore;

/* loading the data in playstore table from an external file */
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Data/playstore.csv"
into table playstore
fields terminated by ','
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from playstore;

/*1.You're working as a market analyst for a mobile app development company. Your task is to identify the most promising categories (TOP 5)
 for launching new free apps based on their average ratings.*/
 
SELECT 
    Category, ROUND(AVG(Rating), 2) AS 'avg'
FROM
    playstore
WHERE
    Type = 'Free'
GROUP BY Category
ORDER BY avg DESC
LIMIT 5;
 
 /*2.As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most revenue from paid apps.
 This calculation is based on the product of the app price and its number of installations.*/
SELECT 
    category, ROUND(AVG(revenue), 2) AS 'avg_revenue'
FROM
    (SELECT 
        category, Price, Installs, (Price * Installs) AS 'revenue'
    FROM
        playstore
    WHERE
        type = 'paid') t
GROUP BY category
ORDER BY avg_revenue DESC
LIMIT 3;
 
 /*3.As a data analyst for a gaming company, you're tasked with calculating the percentage of games(apps) within each category. This information will help the company
 understand the distribution of gaming apps across different categories.*/
SELECT 
    category,
    app_count / (SELECT 
            COUNT(*)
        FROM
            playstore) * 100
FROM
    (SELECT 
        category, COUNT(app) AS 'app_count'
    FROM
        playstore
    GROUP BY Category) t; 
 
 /*4.As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should develop paid or free apps for each category
 based on the ratings of that category.*/
 
 WITH cte1 AS (SELECT category, ROUND(AVG(Rating),2) AS 'avg_paid_rating' FROM playstore WHERE TYPE = 'paid' GROUP BY category), 
cte2 AS( SELECT category, ROUND(AVG(Rating),2) AS 'avg_free_rating' FROM playstore WHERE TYPE = 'free' GROUP BY category) 
SELECT cte1.category, avg_paid_rating, avg_free_rating, IF(avg_paid_rating > avg_free_rating, 'paid', 'free') AS recommended_app
FROM cte1
INNER JOIN cte2
 ON cte1.category = cte2.category;
 
/* 5. As a business analyst you need to analyse which are top 10 category most popular in market as by no of installs */
SELECT 
    category, SUM(installs) AS 'total_installs'
FROM
    playstore
GROUP BY category
ORDER BY total_installs DESC
LIMIT 10; 

/*6.Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the database, 
it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be changed, do some measure
 where the changes in price can be recorded as you can’t stop hackers from making changes.*/
  CREATE TABLE pricechangelog (
    app VARCHAR(200),
    old_price FLOAT,
    new_price FLOAT,
    operation VARCHAR(200),
    operation_date DATETIME
)
  SET sql_safe_updates = 0;
SELECT 
    *
FROM
    pricechangelog;
CREATE TABLE play AS SELECT * FROM
    playstore;
  
  DELIMITER //
  CREATE TRIGGER price_change_log 
  AFTER UPDATE ON play
  FOR EACH ROW
  BEGIN
   INSERT INTO pricechangelog( app, old_price, new_price, operation, operation_date)
   VALUES (NEW.app, OLD.price, NEW.price, 'update', current_timestamp);
  END;
  // DELIMITER ;
  
  /* we will make some updates in the play table */
UPDATE play 
SET 
    price = 4
WHERE
    app = 'Infinite Painter';
    
UPDATE play 
SET 
    price = 8
WHERE
    app = 'Coloring book moana';
    
UPDATE play 
SET 
    price = 12
WHERE
    app = 'Sketch - Draw & Paint';
    
UPDATE play 
SET 
    price = 2
WHERE
    app = 'Paper flowers instructions';
  
  SELECT 
    *
FROM
    pricechangelog; 
  
/*7.Your IT team have neutralized the threat; however, hackers have made some changes in the prices, 
but because of your measure you have noted the changes, now you want correct data to be inserted into the database again.*/
  DROP TRIGGER price_change_log;
SET sql_safe_updates = 0;
UPDATE play AS a
INNER JOIN pricechangelog AS b
ON a.app = b.app
SET a.price = b.old_price
WHERE a.app IS NOT NULL;

/*8.As a data person you are assigned the task of investigating the correlation between two numeric factors: app ratings and the quantity of reviews.*/
SET @x = (SELECT AVG(rating) FROM playstore);
SELECT @x;
SET @y = (SELECT AVG(Reviews) FROM playstore);
SELECT @y;
WITH cte1 AS
(SELECT app, ROUND(rating-@x,2) AS 'avg_rating_deviation', ROUND((Reviews-@y),2) AS 'avg_review_deviation', ROUND((rating-@x)*(rating-@x),2) AS 'rating_deviation_sqr',
ROUND((Reviews-@y)*(Reviews-@y),2) AS 'review_deviation_sqr' FROM playstore)
SELECT ROUND(SUM(avg_rating_deviation * avg_review_deviation)/SQRT(SUM(rating_deviation_sqr)*SUM(review_deviation_sqr)),3) AS 'correlation' FROM cte1; 

/*9.Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue when developing the recommender system from the data 
he/she assigned you the task to clean the genres column and make two genres out of it, rows that have only one genre will have other column as blank.*/
SELECT  
    *,
    SUBSTRING_INDEX(genres, ';', 1) AS first_genre,
    CASE
        WHEN genres LIKE '%;%' THEN SUBSTRING_INDEX(genres, ';', -1)
        ELSE NULL
    END AS second_genres
FROM playstore;

/*10. As a market analyst in a company, you are assigned the task of analysing how much percantage of app market is filled with paid apps. */
SELECT 
    ROUND(COUNT(CASE
                WHEN price > 0 THEN 1
            END) * 100.0 / (COUNT(*)),
            2) AS 'paid_app_market_perc'
FROM
    playstore;
    
/*11. As a Data Analyst in a company, your team have been assigned task to identify high-performing apps that are above average in both ratings and reviews
—as these are more likely to be successful in terms of user retention and word-of-mouth promotion.*/
SELECT 
    app, rating, Reviews
FROM
    playstore
WHERE
    rating > (SELECT 
            AVG(rating)
        FROM
            playstore
        WHERE
            rating IS NOT NULL)
        AND Reviews > (SELECT 
            AVG(Reviews)
        FROM
            playstore
        WHERE
            Reviews IS NOT NULL);
 
/* 12.Your senior manager wants to know which apps are not performing as par in their particular category, however he is not interested in handling too many
 files or list for every  category and he/she assigned  you with a task of creating a dynamic tool where he/she  can input a category of apps he/she  interested 
 in and your tool then provides real-time feedback by displaying apps within that category that have ratings lower than the average rating for that specific category.*/
 DELIMITER $$

CREATE PROCEDURE GetAppsBelowAvgRating(IN app_category VARCHAR(255))
BEGIN
    SELECT 
        app, 
        rating, 
        category
    FROM 
        playstore
    WHERE 
        category = app_category
    AND 
        rating < (SELECT AVG(rating) FROM playstore WHERE category = app_category);
END$$

DELIMITER ;
CALL GetAppsBelowAvgRating('ART_AND_DESIGN');

/*13. You are working as a Database Administrator at a company that tracks app performance data for Google Play Store apps. The team wants to monitor and log any changes
 to app ratings because these changes can signal issues such as bugs or successful updates. Every time an app's rating is updated, the company needs to log the old rating,
 the new rating, and the date of the update.*/
 -- creating a table to log rating changes
 CREATE TABLE log_rating_changes (
    app_name VARCHAR(100),
    old_rating FLOAT,
    new_rating FLOAT,
    update_time TIMESTAMP
);
 
 DELIMITER //

CREATE TRIGGER updated_rating
AFTER UPDATE ON playstore
FOR EACH ROW
BEGIN
    IF OLD.rating <> NEW.rating THEN
        INSERT INTO log_rating_changes(app_name, old_rating, new_rating, update_time) 
        VALUES (NEW.app, OLD.rating, NEW.rating, CURRENT_TIMESTAMP);
    END IF; 
END; //

DELIMITER ; 














 