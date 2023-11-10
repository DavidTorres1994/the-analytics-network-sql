CREATE OR REPLACE PROCEDURE etl.sp_dim_supplier_product()
LANGUAGE sql AS $$
    with stg_supplier as (SELECT dp.product_code, s.name, s.is_primary
    FROM dim.product_master dp
    INNER JOIN stg.supplier s ON dp.product_code = s.product_id
    where is_primary = true)

    INSERT INTO dim.supplier(product_id, name,is_primary)
    SELECT product_code,name,is_primary
    FROM stg_supplier;
$$;

call etl.sp_dim_supplier_product()
