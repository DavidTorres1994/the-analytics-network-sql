create or replace procedure etl.sp_fct_order_line_sale()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 alter table fct.order_line_sale
 add column if not exists line_key serial unique;
 
 insert into fct.order_line_sale(order_number,product,store,date,quantity,sale,promotion,tax,credit,currency,pos,is_walkout)
 select order_number,product,store,date,quantity,sale,promotion,tax,credit,currency,pos,is_walkout
 from stg.order_line_sale
 on conflict(order_number,product) do nothing;
 
	--sp de logg
    call etl.log('fct.order_line_sale', current_date,'etl.sp_fct_order_line_sale',user_name);
    END;
$$;

call etl.sp_fct_order_line_sale()
