create or replace procedure etl.sp_fct_store_traffic()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;

 
 insert into fct.store_traffic(store_id,date,traffic)
 select store_id,date,traffic
 from stg.vw_store_traffic
 on conflict(store_id,date) do nothing;
 
	--sp de logg
    call etl.log('fct.store_traffic', current_date,'etl.sp_fct_store_traffic',user_name);
    END;
$$;

call etl.sp_fct_store_traffic()
