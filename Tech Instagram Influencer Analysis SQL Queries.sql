--            Tech Instagram Influencer Analysis: SQL

# 1) How many unique post types are found in the 'fact_content' table?


SELECT 
    COUNT(DISTINCT post_type) AS Unique_Post_Type_Count
FROM 
    fact_content;

# 2) What are the highest and lowest recorded impressions for each post type?


SELECT 
    post_type, 
    MAX(impressions) AS Highest_Impression, 
    MIN(impressions) AS Lowest_Impression
FROM 
    fact_content
GROUP BY 
    post_type;


# 3) Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.

 
SELECT 
    dd.*, 
    fa.profile_visits, 
    fa.new_followers, 
    fc.impressions, 
    fc.reach, 
    fc.shares, 
    fc.follows, 
    fc.likes, 
    fc.comments, 
    fc.saves 
FROM 
    dim_dates dd
JOIN 
    fact_account fa ON dd.date = fa.date
JOIN 
    fact_content fc ON fa.date = fc.date
WHERE 
    dd.weekday_or_weekend = 'Weekend' 
    AND dd.month_name IN ('March', 'April');


 # 4) Create a report to get the statistics for the account. The final output includes the following fields:
-- • month_name
-- • total_profile_visits
-- • total_new_followers


SELECT 
    MONTHNAME(date) AS month_name, 
    SUM(profile_visits) AS total_profile_visits, 
    SUM(new_followers) AS total_new_followers
FROM 
    fact_account
GROUP BY 
    month_name;


# 5) Write a CTE that calculates the total number of 'likes’ for each 'post_category' during the month of 'July' and subsequently,
-- arrange the 'post_category' values in descending order according to their total likes.


WITH cte AS (
    SELECT 
        post_category, 
        SUM(likes) AS total_likes
    FROM 
        fact_content
    WHERE 
        MONTHNAME(date) = 'July'
    GROUP BY 
        post_category
)
SELECT 
    * 
FROM 
    cte
ORDER BY 
    total_likes DESC;


# 6) Create a report that displays the unique post_category names alongside their respective counts for each month. The output should have three columns:
-- • month_name
-- • post_category_names
-- • post_category_count
/* Example:
• 'April', 'Earphone,Laptop,Mobile,Other Gadgets,Smartwatch', '5'
• 'February', 'Earphone,Laptop,Mobile,Smartwatch', '4' */


SELECT 
    MONTHNAME(date) AS month_name, 
    GROUP_CONCAT(DISTINCT post_category ORDER BY post_category SEPARATOR ', ') AS post_category_names, 
    COUNT(DISTINCT post_category) AS post_category_count
FROM 
    fact_content
GROUP BY 
    MONTH(date), MONTHNAME(date)
ORDER BY 
    MONTH(date);


# 7) What is the percentage breakdown of total reach by post type? The final output includes the following fields:
-- • post_type
-- • total_reach
-- • reach_percentage


SELECT 
    post_type, 
    SUM(reach) AS total_reach, 
    ROUND((SUM(reach) / total_overall_reach) * 100, 2) AS reach_percentage
FROM 
    (SELECT *, (SELECT SUM(reach) FROM fact_content) AS total_overall_reach FROM fact_content) fc
GROUP BY 
    post_type, total_overall_reach
ORDER BY 
    reach_percentage DESC;


# 8) Create a report that includes the quarter, total comments, and total saves recorded for each post category. Assign the following quarter groupings:
-- (January, February, March) → “Q1”
-- (April, May, June) → “Q2”
-- (July, August, September) → “Q3”
/* The final output columns should consist of:
• post_category
• quarter
• total_comments
• total_saves */


SELECT 
    post_category,
    CASE 
        WHEN MONTH(date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(date) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4' -- Optional, if you want to include Q4 (October - December)
    END AS quarter,
    SUM(comments) AS total_comments,
    SUM(saves) AS total_saves
FROM 
    fact_content
GROUP BY 
    post_category, quarter
ORDER BY 
    quarter, total_comments DESC;
    
    
# 9) List the top three dates in each month with the highest number of new followers. The final output should include the following columns:
-- • month
-- • date
-- • new_followers 


WITH ranked_followers AS (
    SELECT 
        MONTHNAME(date) AS month_name, 
        date, 
        new_followers,
        RANK() OVER (PARTITION BY MONTH(date) ORDER BY new_followers DESC) AS rank_num
    FROM 
        fact_account
)
SELECT 
    month_name, 
    date, 
    new_followers
FROM 
    ranked_followers
WHERE 
    rank_num <= 3
ORDER BY 
    MONTH(date), new_followers DESC;
    
    
# 10) Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. 
/* The output of the procedure should consist of two columns:
• post_type
• total_shares */ 


DELIMITER $$

CREATE PROCEDURE GetTotalSharesByPostType(IN week_no INT)
BEGIN
    SELECT 
        post_type, 
        SUM(shares) AS total_shares
    FROM 
        fact_content
    WHERE 
        WEEK(date, 1) = week_no
    GROUP BY 
        post_type
    ORDER BY 
        total_shares DESC;
END $$

DELIMITER ;
