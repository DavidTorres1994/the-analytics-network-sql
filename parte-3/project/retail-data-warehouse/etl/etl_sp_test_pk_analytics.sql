CREATE OR REPLACE PROCEDURE etl.sp_test_pk_analytics()
LANGUAGE plpgsql as $$

BEGIN 
IF EXISTS (
        SELECT order_number, product_code,count(1)
        FROM analytics.order_sale_line
        GROUP BY 1, 2
        HAVING count(1) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicados encontrados en order_sale_line';
    END IF;

    IF EXISTS (
        SELECT order_number, product_code,count(1)
        FROM analytics.return
        GROUP BY 1, 2
        HAVING count(1) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicados encontrados en return';
    END IF;

    IF EXISTS (
        SELECT order_number,product_code,count(1)
        FROM analytics.inventory
        GROUP BY 1,2
        HAVING count(1) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicados encontrados en inventory';
    END IF;
  END;
$$;

call etl.sp_test_pk_analytics()
call etl.sp_test_pk_analytics()
