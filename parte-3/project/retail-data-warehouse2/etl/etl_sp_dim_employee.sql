create or replace procedure etl.sp_dim_employee()
language plpgsql as $$ 
--declarar variable
declare user_name varchar(10) := current_user;
begin user_name := current_user;
 alter table dim.employee
 add column if not exists is_active boolean;
 alter table dim.employee
 add column if not exists duration smallint;

 insert into dim.employee(id,employee_key,name, surname,start_date,end_date,phone,country,province,store_id,
	 position, current_flag,effective_start_date,effective_end_date)
 select id,employee_key,name, surname,start_date,end_date,phone,country,province,store_id,
	 position, current_flag,effective_start_date,effective_end_date
 from stg.employee
 on conflict(id) do nothing;
 
	--sp de logg
    call etl.log('dim.employee', current_date,'etl.sp_dim_employee',user_name);
    END;
$$;
