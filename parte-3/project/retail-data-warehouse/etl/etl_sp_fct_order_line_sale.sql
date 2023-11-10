CREATE OR REPLACE PROCEDURE etl.sp_fct_order_line_sale()
LANGUAGE sql AS $$    
  
    INSERT INTO fct.order_line_sale(order_number,product,store,date,quantity,sale,promotion,tax,credit,currency,pos,is_walkout)
    SELECT order_number,product,store,date,quantity,sale,promotion,tax,credit,currency,pos,is_walkout
    FROM stg.order_line_sale;

    ALTER TABLE fct.order_line_sale
        ADD COLUMN IF NOT EXISTS line_key SERIAL UNIQUE;
  $$;
call etl.sp_fct_order_line_sale()
