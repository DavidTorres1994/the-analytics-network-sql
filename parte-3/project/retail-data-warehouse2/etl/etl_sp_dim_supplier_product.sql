create or replace procedure etl.sp_dim_supplier_product()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 alter table dim.supplier
 add column if not exists supplier_key  serial unique; 
 with cte as (
   select s.product_id,s.name,s.is_primary
	from stg.product_master pm
	left join stg.supplier s on s.product_id=pm.product_code
    where is_primary=true)
 insert into dim.supplier(product_id,name,is_primary)
 select product_id,name,is_primary
 from cte
 on conflict(supplier_key) do nothing;
 
	--sp de logg
    call etl.log('dim.supplier', current_date,'etl.sp_dim_supplier_product',user_name);
    END;
$$;

call etl.sp_dim_supplier_product()
