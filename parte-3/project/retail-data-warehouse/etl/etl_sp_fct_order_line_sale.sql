CREATE OR REPLACE PROCEDURE etl.sp_fct_order_line_sale()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;  
     ALTER TABLE fct.order_line_sale
        ADD COLUMN IF NOT EXISTS line_key SERIAL UNIQUE;
    INSERT INTO fct.order_line_sale(order_number,product,store,date,quantity,sale,promotion,tax,credit,currency,pos,is_walkout)
    SELECT ol.order_number,ol.product,ol.store,ol.date,ol.quantity,ol.sale,ol.promotion,ol.tax,ol.credit,ol.currency,ol.pos,ol.is_walkout
    FROM stg.order_line_sale ol
    on conflict(order_number, product) do nothing; 
    --WHERE NOT EXISTS (
    --    SELECT 1
     --   FROM fct.order_line_sale f
     --   WHERE f.order_number = ol.order_number
	--	 and  f.product = ol.product
	--	 and  f.store = ol.store
	--	 and  f.date = ol.date
    --);
--sp de logg
    call etl.log('fct.order_line_sale', current_date, 'etl.sp_fct_order_line_sale',username);
END;
  $$;
call etl.sp_fct_order_line_sale()
