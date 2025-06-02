-- =====================================================
-- Marketing Analytics SQL Queries
-- Author: Osama Audi
-- Description: Data cleaning, enrichment, categorization, and reporting
-- =====================================================

-- 🔹 Explore Raw Customer Journey Data
SELECT * 
FROM dbo.customer_journey;

-- =====================================================
-- 🔍 Remove Duplicate Records from Customer Journey
-- =====================================================
WITH DuplicateRecords AS (
    SELECT
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        Stage,
        Action,
        Duration,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
            ORDER BY JourneyID
        ) AS row_num
    FROM dbo.customer_journey
)

-- Return only the duplicate rows (row_num > 1)
SELECT *
FROM DuplicateRecords
WHERE row_num > 1
ORDER BY JourneyID;

-- =====================================================
-- ✅ Clean and Standardize Customer Journey Data
-- =====================================================
SELECT 
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COALESCE(Duration, avg_duration) AS Duration -- Fill missing durations with daily average
FROM (
    SELECT	
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        UPPER(Stage) AS Stage, -- Standardize text case
        Action,
        Duration,
        AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
            ORDER BY JourneyID
        ) AS row_num
    FROM dbo.customer_journey
) AS subquery 
WHERE row_num = 1;

-- =====================================================
-- 🛒 View Product Data
-- =====================================================
SELECT * 
FROM dbo.products;

-- Categorize Products by Price Range
SELECT 
    ProductID,
    ProductName,
    Price,
    CASE 
        WHEN Price < 50 THEN 'Low'
        WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END AS PriceCategory
FROM dbo.products;

-- =====================================================
-- 👤 View Customer and Geography Info
-- =====================================================
SELECT * FROM dbo.customers;
SELECT * FROM dbo.geography;

-- Join Customers with Their Geographic Data
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Gender,
    c.Age,
    g.Country,
    g.City
FROM dbo.customers AS c
LEFT JOIN dbo.geography AS g
    ON c.GeographyID = g.GeographyID;

-- =====================================================
-- ⭐ Customer Reviews Cleanup
-- =====================================================
SELECT * 
FROM dbo.customer_reviews;

-- Clean Extra Whitespace from Review Text
SELECT 
    ReviewID,
    CustomerID,
    ProductID,
    ReviewDate,
    Rating,
    REPLACE(ReviewText, '  ', ' ') AS ReviewText
FROM dbo.customer_reviews;

-- =====================================================
-- 📈 Engagement Data Exploration and Cleanup
-- =====================================================
SELECT * 
FROM dbo.engagement_data;

-- Clean and Structure Engagement Metrics
SELECT 
    EngagementID,
    ContentID,
    CampaignID,
    ProductID,
    UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
    Likes,
    FORMAT(CONVERT(date, EngagementDate), 'MM/dd/yyyy') AS EngagementDate
FROM dbo.engagement_data
WHERE ContentType != 'NewsLetter'; -- Exclude irrelevant content



