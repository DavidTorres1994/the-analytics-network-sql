CREATE OR REPLACE PROCEDURE etl.sp_dim_cost()
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dim.cost(product_id, cost_usd)
    SELECT dp.product_code, dc.cost_usd
    FROM dim.product_master dp
    LEFT JOIN dim.cost dc ON dp.product_code = dc.product_id;

    EXCEPTION
        WHEN unique_violation THEN
            UPDATE dim.cost
            SET cost_usd = EXCLUDED.cost_usd
            WHERE product_id = EXCLUDED.product_id;
END;
$$;
