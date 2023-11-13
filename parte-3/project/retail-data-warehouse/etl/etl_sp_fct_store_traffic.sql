CREATE OR REPLACE PROCEDURE etl.sp_fct_store_traffic()
LANGUAGE plpgsql as $$
-- declaracion de variables
DECLARE username varchar(10) := current_user;
BEGIN username := current_user;
--transformación
   with store_traffic as (
    SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
    FROM stg.super_store_count sc
    UNION ALL
    SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
    FROM stg.market_count mc)
--insert  
    INSERT INTO fct.store_traffic(store_id,date,traffic)
    SELECT store_id,date,traffic
    FROM store_traffic st
    --ON conflict(store_id, date) do nothing;
	WHERE NOT EXISTS (
        SELECT 1
        FROM fct.store_traffic ft
        WHERE ft.store_id = st.store_id
		and ft.date=st.date
	              ); 
    --sp de logg
    call etl.log('fct.store_traffic', current_date, 'sp_fct_store_traffic',username);
  END;
  $$;
  
call etl.sp_fct_store_traffic()
