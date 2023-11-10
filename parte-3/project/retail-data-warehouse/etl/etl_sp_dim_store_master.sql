CREATE OR REPLACE PROCEDURE etl.sp_dim_store_master()
LANGUAGE plpgsql AS $$    
BEGIN
    INSERT INTO dim.store_master(store_id,country,province,city,address,name,type,start_date)
    SELECT store_id,country,province,city,address,name,type,start_date
    FROM stg.store_master
    ON CONFLICT(store_id) DO UPDATE
    SET country = EXCLUDED.country,
        province = EXCLUDED.province,
        city = EXCLUDED.city,
        address = EXCLUDED.address,
        name = EXCLUDED.name,
        type = EXCLUDED.type,
        start_date = EXCLUDED.start_date;
    
END;
$$;

call etl.sp_dim_store_master()
