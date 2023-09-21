
-- General 
-- - Ventas brutas, netas y margen (USD)
-- ventas brutas
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month, sum(Ventas_en_dolares)AS sales_usd
from order_line_Sale_dollars
group by Year, Month
order by Year, Month
-- ventas netas
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month, sum(Ventas_en_dolares-Descuento_en_dolares)AS net_sales_usd
from order_line_Sale_dollars
group by Year, Month
order by Year, Month
--margen
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month, sum(Ventas_en_dolares-Descuento_en_dolares-costo_linea)AS margin_usd
from order_line_Sale_dollars
group by Year, Month
order by Year, Month
-- - Margen por categoria de producto (USD)
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product,pm.category, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)
select category, sum(Ventas_en_dolares-Descuento_en_dolares-costo_linea)AS margin_usd
from order_line_Sale_dollars
group by category

-- - ROI por categoria de producto. ROI = ventas netas / Valor promedio de inventario (USD)
with inventory_dollars as (SELECT date,store_id,item_id,category,
	  (c.product_cost_usd*(i.initial+i.final)/2) as costo_inv_prom
from stg.inventory i
left join stg.cost c on c.product_code=i.item_id
left join stg.product_master pm on pm.product_code=c.product_code),
order_line_Sale_dollars as (SELECT cast(date_trunc('month',os.date) as date) as date,store,product,category,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS Descuento_en_dolares,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)

select extract(year from osd.date)as Year,extract(month from osd.date)as Month,osd.category, sum(Ventas_en_dolares-Descuento_en_dolares)/sum(costo_inv_prom) as roi
from order_line_Sale_dollars osd
left join inventory_dollars id on osd.date=id.date and osd.store=id.store_id and osd.product=id.item_id and osd.category=id.category
group by  Year, Month,osd.category
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

