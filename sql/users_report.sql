-- Drop table if exists (SQL Server compatible with all versions)
IF OBJECT_ID('gold.user_report', 'U') IS NOT NULL
    DROP TABLE gold.user_report;

WITH orders_agg AS (
    SELECT 
        userid,
        COUNT(orderid) AS totalorders,
        SUM(orderamount) AS totalspent,
        ROUND(CAST(AVG(orderamount) AS float),2) AS avg_ordervalue,
        MAX(orderdate) AS lastorder,
        MIN(orderdate) AS firstorder
    FROM silver.orders 
    GROUP BY userid
),

items_agg AS (
    SELECT 
        o.userid,
        COUNT(i.order_itemid) AS totalitems
    FROM silver.order_items i
    JOIN silver.orders o ON i.orderid = o.orderid
    GROUP BY o.userid
),

events_agg AS (
    SELECT 
        userid,
        COUNT(*) AS total_events,
        COUNT(CASE WHEN eventtype = 'view' THEN 1 END) AS total_views,
        COUNT(CASE WHEN eventtype = 'cart' THEN 1 END) AS total_cart,
        COUNT(CASE WHEN eventtype = 'purchase' THEN 1 END) AS total_purchase_events
    FROM silver.events
    GROUP BY userid
),

reviews_agg AS (
    SELECT
        userid,
        AVG(rating) AS avg_rate
    FROM silver.reviews
    GROUP BY userid
),

base AS (
    SELECT
        u.userid,
        u.username,
        u.usergender,
        u.useremail,
        u.usercity,
        u.usersigndate,

        COALESCE(o.totalorders, 0) AS totalorders,
        COALESCE(o.totalspent, 0) AS totalspent,
        COALESCE(o.avg_ordervalue, 0) AS avg_ordervalue,
        o.firstorder,
        o.lastorder,

        COALESCE(i.totalitems, 0) AS totalitems,

        COALESCE(e.total_events, 0) AS total_events,
        COALESCE(e.total_views, 0) AS total_views,
        COALESCE(e.total_cart, 0) AS total_cart,
        COALESCE(e.total_purchase_events, 0) AS total_purchase_events,

        r.avg_rate

    FROM silver.users u
    LEFT JOIN orders_agg o ON o.userid = u.userid
    LEFT JOIN items_agg i ON i.userid = u.userid
    LEFT JOIN events_agg e ON e.userid = u.userid
    LEFT JOIN reviews_agg r ON r.userid = u.userid
),

--  Feature Engineering
features AS (
    SELECT *,
        DATEDIFF(DAY, lastorder, MAX(lastorder) OVER()) AS recencydays,
        DATEDIFF(DAY, firstorder, lastorder) AS timespan,

        CASE 
            WHEN firstorder >= usersigndate 
            THEN DATEDIFF(DAY, usersigndate, firstorder)
            ELSE 0
        END AS days_to_first_purchase
    FROM base
),


scored AS (
    SELECT *,

        CASE 
            WHEN totalorders < 1 THEN 1
            WHEN totalorders = 2 THEN 2
            WHEN totalorders BETWEEN 3 AND 4 THEN 3
            WHEN totalorders BETWEEN 5 AND 7 THEN 4
            ELSE 5
        END AS frequencyscore,

        CASE 
            WHEN totalspent < 500 THEN 1
            WHEN totalspent < 1000 THEN 2
            WHEN totalspent < 2000 THEN 3
            WHEN totalspent < 5000 THEN 4
            ELSE 5
        END AS monetaryscore,

        CASE
            WHEN recencydays <= 30 THEN 5
            WHEN recencydays <= 90 THEN 4
            WHEN recencydays <= 180 THEN 3
            WHEN recencydays <= 365 THEN 2
            ELSE 1
        END AS recencyscore

    FROM features
)


SELECT *,
    CASE 
        WHEN recencyscore >= 4 AND frequencyscore >= 4 AND monetaryscore >= 4 THEN 'Champion'
        WHEN frequencyscore >= 4 AND recencyscore >= 3 THEN 'Loyal'
        WHEN recencyscore = 5 AND frequencyscore = 1 THEN 'New'
        WHEN recencyscore <= 2 AND frequencyscore >= 3 THEN 'At Risk'
        WHEN recencyscore = 1 THEN 'Lost'
        ELSE 'Regular'
    END AS rfmsegment
INTO gold.user_report
FROM scored;