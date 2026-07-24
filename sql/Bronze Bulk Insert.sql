USE portfolio;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        /* =========================
           EVENTS
        ========================== */
        TRUNCATE TABLE bronze.events;
        PRINT 'Loading events';

        BULK INSERT bronze.events
        FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\events.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           ORDER ITEMS
        ========================== */
        TRUNCATE TABLE bronze.order_items;
        PRINT 'Loading order_items';
        BULK INSERT bronze.order_items
        FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\order_items.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           ORDERS
        ========================== */
        TRUNCATE TABLE bronze.orders;
        PRINT 'Loading orders';

        BULK INSERT bronze.orders
        FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\orders.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           PRODUCTS
        ========================== */
        TRUNCATE TABLE bronze.products;
        PRINT 'Loading products';

        BULK INSERT bronze.products
        FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        /* =========================
           REVIEWS
        ========================== */
        TRUNCATE TABLE bronze.reviews;
        PRINT 'Loading reviews';

        BULK INSERT bronze.reviews
FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\reviews_fixed.csv'
WITH (
    FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
    TABLOCK
);


        /* =========================
           USERS
        ========================== */
        TRUNCATE TABLE bronze.users;
        PRINT 'Loading users';

        BULK INSERT bronze.users
        FROM 'C:\Users\LENOVO\Downloads\archive\ecommerce_dataset\users.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR  = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'Bronze load completed successfully';

    END TRY
    BEGIN CATCH
        PRINT 'ERROR DURING BRONZE LOAD';
        PRINT ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
