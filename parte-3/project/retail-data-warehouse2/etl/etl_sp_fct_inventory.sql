create or replace procedure etl.sp_fct_inventory()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 
 
 insert into fct.inventory(date,store_id,item_id,initial,final)
 select date,store_id,item_id,initial,final
 from stg.inventory
 on conflict(date,store_id,item_id) do nothing;
 
	--sp de logg
    call etl.log('fct.inventory', current_date,'etl.sp_fct_inventory',user_name);
    END;
$$;

call etl.sp_fct_inventory()
