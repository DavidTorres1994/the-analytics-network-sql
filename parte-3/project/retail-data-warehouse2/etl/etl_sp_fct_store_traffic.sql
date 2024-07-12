create or replace procedure etl.sp_fct_store_traffic()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;

with cte as (
select mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD') AS date, mc.traffic 
from stg.market_count mc
UNION ALL
select sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD') AS date, sc.traffic 
from stg.super_store_count sc)
 
 insert into fct.store_traffic(store_id,date,traffic)
 select store_id,date,traffic
 from cte
 on conflict(store_id,date) do nothing;
 
	--sp de logg
    call etl.log('fct.store_traffic', current_date,'etl.sp_fct_store_traffic',user_name);
    END;
$$;

call etl.sp_fct_store_traffic()
