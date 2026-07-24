IF OBJECT_ID('gold.product_report', 'U') IS NOT NULL
    DROP TABLE gold.product_report;
WITH items_agg AS
(select  
      p.productid,
	  p.productname,
	  p.productcategory,
	  p.productbrand,
	  p.productprice,
	  p.productrating,
	  COUNT(i.orderid) totalorders,
	  SUM(i.quantity) totalquantity,
	  SUM(i.itemtotal) totalrevenue,
	  COUNT(DISTINCT i.userid)  totalcustomers

from silver.products p
left join silver.order_items i
on i.productid=p.productid
      GROUP BY  p.productid,
	  p.productname,
	  p.productcategory,
	  p.productbrand,
	  p.productprice,
	  p.productrating
),
events_agg AS (

    SELECT
        productid,

        COUNT(CASE WHEN eventtype = 'view' THEN 1 END) AS totalviews,

        COUNT(CASE WHEN eventtype = 'cart' THEN 1 END) AS totalcarts,

        COUNT(CASE WHEN eventtype = 'purchase' THEN 1 END) AS totalpurchases

    FROM silver.events

    GROUP BY productid
),
reviews_agg AS (
    SELECT
        productid,
        COUNT(reviewid) AS totalreviews
    FROM silver.reviews
    GROUP BY productid
),

base AS (
   SELECT
      i.productid,
	  i.productname,
	  i.productcategory,
	  i.productbrand,
	  i.productprice,
	  i.productrating,
	  i.totalorders,
	  i.totalquantity,
	  i.totalrevenue,
	  i.totalcustomers,
	  e.totalviews,
	  e.totalcarts,
	  e.totalpurchases,
	  r.totalreviews
    FROM items_agg i
	LEFT JOIN events_agg e
	on i.productid=e.productid
	LEFT JOIN reviews_agg r
	ON r.productid=i.productid
)
SELECT 
    *,
	CASE
        WHEN productprice < 50 THEN 'Budget'
        WHEN productprice < 200 THEN 'Affordable'
        WHEN productprice < 500 THEN 'Mid-Range'
        WHEN productprice < 1000 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_segment,

    /* Rating Segment */
    CASE
        WHEN productrating >= 4.5 THEN 'Excellent'
        WHEN productrating >= 4.0 THEN 'Highly Rated'
        WHEN productrating >= 3.5 THEN 'Average'
        WHEN productrating >= 3.0 THEN 'Below Average'
        ELSE 'Low Rated'
    END AS rating_segment,

    /* Order Volume Segment */
    CASE
        WHEN totalorders >= 30 THEN 'Best Seller'
        WHEN totalorders >= 21 THEN 'Strong Seller'
        WHEN totalorders >= 15 THEN 'Moderate Seller'
        ELSE 'Low Seller'
    END AS order_segment,

    /* Quantity Demand Segment */
    CASE
        WHEN totalquantity >= 45 THEN 'High Demand'
        WHEN totalquantity >= 30 THEN 'Good Demand'
        WHEN totalquantity >= 20 THEN 'Moderate Demand'
        ELSE 'Low Demand'
    END AS demand_segment,

    /* Revenue Segment */
    CASE
        WHEN totalrevenue >= 20000 THEN 'Elite Revenue'
        WHEN totalrevenue >= 6000 THEN 'High Revenue'
        WHEN totalrevenue >= 2000 THEN 'Medium Revenue'
        ELSE 'Low Revenue'
    END AS revenue_segment,

    /* Customer Reach Segment */
    CASE
        WHEN totalcustomers >= 30 THEN 'Mass Reach'
        WHEN totalcustomers >= 21 THEN 'Wide Reach'
        WHEN totalcustomers >= 15 THEN 'Moderate Reach'
        ELSE 'Niche Reach'
    END AS customer_segment,

    /* Main Strategic Product Classification */
    CASE
        WHEN totalrevenue >= 20000 
             AND totalorders >= 30 
             AND productrating >= 4.0
        THEN 'Star Product'

        WHEN totalorders >= 21 
             AND totalrevenue >= 6000
        THEN 'Core Product'

        WHEN productrating >= 4.5 
             AND totalorders < 21
        THEN 'Hidden Gem'

        WHEN productprice >= 1000 
             AND totalorders < 15
        THEN 'High Ticket Low Volume'

        WHEN totalrevenue < 2000 
             AND totalorders < 15
        THEN 'Underperformer'

        ELSE 'Regular Product'
    END AS product_segment
  INTO gold.product_report
FROM base