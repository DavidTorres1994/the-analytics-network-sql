create or replace procedure etl.sp_fct_fx_rate()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;

 
 insert into fct.fx_rate(month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru)
 select month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru
 from stg.monthly_average_fx_rate
 on conflict(month) do nothing;
 
	--sp de logg
    call etl.log('fct.fx_rate', current_date,'etl.sp_fct_fx_rate',user_name);
    END;
$$;

call etl.sp_fct_fx_rate()
