CREATE OR REPLACE PROCEDURE etl.sp_dim_employee()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;
    INSERT INTO dim.employee(id,employee_key,name,surname,start_date,end_date,phone,country,province,store_id,position,current_flag,effective_start_date,effective_end_date)
    SELECT id,employee_key,name,surname,start_date,end_date,phone,country,province,store_id,position,current_flag,effective_start_date,effective_end_date
    FROM stg.employee
    on conflict(id) do nothing;
    -- Añadir una columna si no existe
     ALTER TABLE dim.employee
        ADD COLUMN IF NOT EXISTS is_active BOOLEAN;

        ALTER TABLE dim.employee
        ADD COLUMN IF NOT EXISTS duration INT;
--sp de logg
    call etl.log('dim.employee', current_date, 'etl.sp_dim_employee',username);    
    
END;
$$;
call etl.sp_dim_employee()
