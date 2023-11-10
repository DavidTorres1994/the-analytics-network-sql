CREATE OR REPLACE PROCEDURE etl.sp_fct_store_traffic()
LANGUAGE sql AS $$    
   with store_traffic as (
    SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
    FROM stg.super_store_count sc
    UNION ALL
    SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
    FROM stg.market_count mc)
  
    INSERT INTO fct.store_traffic(store_id,date,traffic)
    SELECT store_id,date,traffic
    FROM store_traffic st
	WHERE NOT EXISTS (
        SELECT 1
        FROM fct.store_traffic ft
        WHERE ft.store_id = st.store_id
		and ft.date=st.date
	              );
  $$;
  
call etl.sp_fct_store_traffic()
