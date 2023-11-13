CREATE OR REPLACE PROCEDURE etl.sp_dim_supplier_product()
LANGUAGE plpgsql AS $$   
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;
    with stg_supplier as (SELECT dp.product_code, s.name, s.is_primary
    FROM dim.product_master dp
    INNER JOIN stg.supplier s ON dp.product_code = s.product_id
    where is_primary = true)

    INSERT INTO dim.supplier(product_id, name,is_primary)
    SELECT product_code,name,is_primary
    FROM stg_supplier;
--sp de logg
    call etl.log('dim.supplier', current_date, 'etl.sp_dim_supplier_product',username);
END;
$$;

call etl.sp_dim_supplier_product()
