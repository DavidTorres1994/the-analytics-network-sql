CREATE OR REPLACE PROCEDURE etl.sp_fct_fx_rate()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;  
  
    INSERT INTO fct.fx_rate(month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru)
    SELECT month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru
     FROM stg.monthly_average_fx_rate mar
    WHERE NOT EXISTS (
        SELECT 1
        FROM fct.fx_rate fr
        WHERE fr.month = mar.month);
 --sp de logg
    call etl.log('fct.fx_rate', current_date, 'etl.sp_fct_fx_rate',username);
END;
  $$;
  
call etl.sp_fct_fx_rate()
