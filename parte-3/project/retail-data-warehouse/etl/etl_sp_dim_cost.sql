CREATE OR REPLACE PROCEDURE etl.sp_dim_cost()
LANGUAGE sql AS $$
    with STG_cost as (SELECT dp.product_code, dc.product_cost_usd
    FROM dim.product_master dp
    INNER JOIN stg.cost dc ON dp.product_code = dc.product_code)

    INSERT INTO dim.cost(product_id, cost_usd)
    SELECT product_code,product_cost_usd
    FROM stg_cost
    ON CONFLICT(product_id) DO UPDATE
    SET cost_usd = EXCLUDED.cost_usd;
$$;
call etl.sp_dim_cost()
