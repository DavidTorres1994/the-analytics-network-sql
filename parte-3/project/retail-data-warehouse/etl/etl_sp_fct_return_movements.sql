CREATE OR REPLACE PROCEDURE etl.sp_fct_return_movements()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;    
     
    INSERT INTO fct.return_movements(order_id,return_id,item,quantity,movement_id,from_location,to_location,received_by,date)
    SELECT r.order_id,r.return_id,r.item,r.quantity,r.movement_id,r.from_location,r.to_location,r.received_by,r.date
    FROM stg.return_movements r
    WHERE NOT EXISTS (
        SELECT 1
        FROM fct.return_movements f
        WHERE f.order_id = r.order_id
		 and  f.return_id = r.return_id
		 and  f.item = r.item
     and  f.movement_id = r.movement_id
    ); 
--sp de logg
    call etl.log('fct.return_movements', current_date, 'etl.sp_fct_return_movements',username);
END;
  $$;
call etl.sp_fct_return_movements()
