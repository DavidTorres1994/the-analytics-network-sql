-- Funcion Conversion de moneda
create or replace function etl.convert_usd(moneda varchar(3),valor decimal(18,5), fecha date) returns decimal(18,5) as $$
select 
coalesce(round(valor/(case 
	when moneda = 'EUR' then mfx.fx_rate_usd_eur
	when moneda = 'ARS' then mfx.fx_rate_usd_peso
	when moneda = 'URU' then mfx.fx_rate_usd_uru
	else 0 end),2),0) as valor_usd
from fct.fx_rate mfx 
where date_trunc( 'month', mfx.month) = date_trunc('month', fecha)
;
$$ language sql;
