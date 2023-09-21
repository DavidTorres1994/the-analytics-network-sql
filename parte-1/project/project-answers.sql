
-- General 
-- - Ventas brutas, netas y margen (USD)
-- Ventas brutas
with ventas_totales_en_dolares as (SELECT os.order_number, os.sale, os.currency, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date)
select extract(year from date)as Year,extract(month from date)as Month, sum(Ventas_en_dolares)AS sales_usd
from ventas_totales_en_dolares
group by Year, Month
order by Year, Month
-- ventas netas
with ventas_netas_en_dolares as (SELECT os.order_number, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN currency = 'EUR' THEN promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN promotion/fx_rate_usd_URU
	  ELSE promotion
	  END AS Descuento_en_dolares	  
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date)
select extract(year from date)as Year,extract(month from date)as Month, sum(Ventas_en_dolares-coalesce(Descuento_en_dolares,0))AS net_sales_usd
from ventas_netas_en_dolares
group by Year, Month
order by Year, Month
-- - Margen por categoria de producto (USD)

-- - ROI por categoria de producto. ROI = ventas netas / Valor promedio de inventario (USD)

-- - AOV (Average order value), valor promedio de la orden. (USD)

-- Contabilidad (USD)
-- - Impuestos pagados

-- - Tasa de impuesto. Impuestos / Ventas netas 

-- - Cantidad de creditos otorgados

-- - Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito

-- Supply Chain (USD)
-- - Costo de inventario promedio por tienda

-- - Costo del stock de productos que no se vendieron por tienda

-- - Cantidad y costo de devoluciones


-- Tiendas
-- - Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra

