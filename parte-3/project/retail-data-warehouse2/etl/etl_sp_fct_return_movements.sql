create or replace procedure etl.sp_fct_return_movements()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 
 
 insert into fct.return_movements(order_id,return_id,item,quantity,movement_id,from_location,to_location,received_by,date)
 select order_id,return_id,item,quantity,movement_id,from_location,to_location,received_by,date
 from stg.return_movements
 on conflict(order_id,movement_id) do nothing;
 
	--sp de logg
    call etl.log('fct.return_movements', current_date,'etl.sp_fct_return_movements',user_name);
    END;
$$;

call etl.sp_fct_return_movements()
