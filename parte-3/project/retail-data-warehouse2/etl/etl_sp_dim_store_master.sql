CREATE OR REPLACE PROCEDURE etl.sp_dim_store_master()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;
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
--sp de logg
    call etl.log('dim.store_master', current_date, 'etl.sp_dim_store_master',username);    
END;
$$;

call etl.sp_dim_store_master()
