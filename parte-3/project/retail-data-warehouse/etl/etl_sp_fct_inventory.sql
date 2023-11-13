CREATE OR REPLACE PROCEDURE etl.sp_fct_inventory()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;  
     
    INSERT INTO fct.inventory(date,store_id,item_id,initial,final)
    SELECT i.date,i.store_id,i.item_id,i.initial,i.final
    FROM stg.inventory i
    WHERE NOT EXISTS (
        SELECT 1
        FROM fct.inventory f
        WHERE f.date = i.date
		 and  f.store_id = i.store_id
		 and  f.item_id = i.item_id

    );
--sp de logg
    call etl.log('fct.inventory', current_date, 'etl.sp_fct_inventory',username);
END;
  $$;
call etl.sp_fct_inventory()
