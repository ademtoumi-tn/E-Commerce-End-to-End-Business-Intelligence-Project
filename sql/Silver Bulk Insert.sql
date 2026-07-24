USE portfolio;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        /* =========================
           EVENTS
        ========================== */
        TRUNCATE TABLE silver.events;
        PRINT 'Loading events';

        BULK INSERT silver.events
        FROM 'C:\Users\LENOVO\Desktop\portfolio\events.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           ORDER ITEMS
        ========================== */
        TRUNCATE TABLE silver.order_items;
        PRINT 'Loading order_items';
        BULK INSERT silver.order_items
        FROM 'C:\Users\LENOVO\Desktop\portfolio\order_items.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           ORDERS
        ========================== */
        TRUNCATE TABLE silver.orders;
        PRINT 'Loading orders';

        BULK INSERT silver.orders
        FROM 'C:\Users\LENOVO\Desktop\portfolio\orders.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           PRODUCTS
        ========================== */
        TRUNCATE TABLE silver.products;
        PRINT 'Loading products';

        BULK INSERT silver.products
        FROM 'C:\Users\LENOVO\Desktop\portfolio\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           REVIEWS
        ========================== */
        TRUNCATE TABLE silver.reviews;
        PRINT 'Loading reviews';

        BULK INSERT silver.reviews
FROM 'C:\Users\LENOVO\Desktop\portfolio\reviews.csv'
WITH (
    FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
    TABLOCK
);


        /* =========================
           USERS
        ========================== */
        TRUNCATE TABLE silver.users;
        PRINT 'Loading users';

        BULK INSERT silver.users
        FROM 'C:\Users\LENOVO\Desktop\portfolio\users.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0d0a',
            CODEPAGE = '65001',
            TABLOCK
        );
		/* ==========================
		    date_table
		============================*/
		TRUNCATE TABLE silver.date_table;

BULK INSERT silver.date_table
FROM 'C:\Users\LENOVO\Desktop\portfolio\date.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR  = '0x0d0a',
    CODEPAGE = '65001',
    TABLOCK
);

        PRINT 'silver load completed successfully';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR DURING SILVER LOAD';
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
