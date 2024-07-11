create or replace procedure etl.sp_dim_date()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 with cte as (
   select d.date,d.month,d.year,initcap(d.dia_de_la_semana) as dia_de_la_semana,d.is_weekend
	 ,initcap(d.month_label) as month_label,d.fiscal_year,initcap(d.fiscal_year_label)as fiscal_year_label,
	 initcap(d.fiscal_quarter_label) as fiscal_quarter_label,
	 d.date_ly
	from stg.date d)
 insert into dim.date(date,month,year,dia_de_la_semana,is_weekend
	 ,month_label,fiscal_year,fiscal_year_label,fiscal_quarter_label,
	 date_ly)
 select *
 from cte
 on conflict(date) do nothing;
 
	--sp de logg
    call etl.log('dim.date', current_date,'etl.sp_dim_date',user_name);
    END;
$$;

call etl.sp_dim_date()
