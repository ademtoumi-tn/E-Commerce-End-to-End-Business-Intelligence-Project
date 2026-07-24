IF OBJECT_ID('gold.orders_report', 'U') IS NOT NULL
    DROP TABLE gold.orders_report;
SELECT
i.orderid,
i.order_itemid,
i.userid,
i.productid,
o.orderdate,
i.itemprice,
i.itemtotal,
o.orderamount,
o.orderstatus
INTO gold.orders_report
FROM silver.order_items i
LEFT JOIN silver.orders o
ON i.orderid = o.orderid