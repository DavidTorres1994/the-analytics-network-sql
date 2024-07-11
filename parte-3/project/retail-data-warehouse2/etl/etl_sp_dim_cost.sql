create or replace procedure etl.sp_dim_cost()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 with cte as (
   select pm.product_code,c.product_cost_usd
	from dim.product_master pm
	left join stg.cost c on c.product_code=pm.product_code
   )
 insert into dim.cost(product_id,cost_usd)
 select *
 from cte
 on conflict(product_id) do update
 set product_id=excluded.product_id,
     cost_usd=excluded.cost_usd;
	--sp de logg
    call etl.log('dim.cost', current_date,'etl.sp_dim_cost',user_name);
    END;
$$;

call etl.sp_dim_cost()
