CREATE OR REPLACE PROCEDURE etl.sp_fct_fx_rate()
LANGUAGE sql AS $$    
  
    INSERT INTO fct.fx_rate(month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru)
    SELECT month,fx_rate_usd_peso,fx_rate_usd_eur,fx_rate_usd_uru
    FROM stg.monthly_average_fx_rate;
  $$;
  
call etl.sp_fct_fx_rate()
