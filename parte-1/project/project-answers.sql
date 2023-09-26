
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month, category, sum(Ventas_en_dolares-Descuento_en_dolares-costo_linea)AS margin_usd
from order_line_Sale_dollars
group by Year, Month, category

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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)

select extract(year from osd.date)as Year,extract(month from osd.date)as Month,osd.category, sum(Ventas_en_dolares-Descuento_en_dolares)/sum(costo_inv_prom) as roi
from order_line_Sale_dollars osd
left join inventory_dollars id on osd.date=id.date and osd.store=id.store_id and osd.product=id.item_id and osd.category=id.category
group by  Year, Month,osd.category
-- - AOV (Average order value), valor promedio de la orden. (USD)
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month,order_number, AVG(Ventas_en_dolares-Descuento_en_dolares)AS aov
from order_line_Sale_dollars
group by Year, Month,order_number
order by Year, Month 
-- Contabilidad (USD)
-- - Impuestos pagados
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
	  CASE
	  WHEN os.tax IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.tax/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.tax/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.tax/fx_rate_usd_URU
	  ELSE os.tax
	  END AS tax_usd,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month,sum(tax_usd)as tax_usd
from order_line_Sale_dollars
group by Year, Month
order by Year, Month
-- - Tasa de impuesto. Impuestos / Ventas netas 
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
	  CASE
	  WHEN os.tax IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.tax/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.tax/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.tax/fx_rate_usd_URU
	  ELSE os.tax
	  END AS tax_usd,
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month,sum(tax_usd/(Ventas_en_dolares-Descuento_en_dolares))as tax_rate
from order_line_Sale_dollars
group by Year, Month
order by Year, Month 
-- - Cantidad de creditos otorgados
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
	  CASE
	  WHEN os.tax IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.tax/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.tax/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.tax/fx_rate_usd_URU
	  ELSE os.tax
	  END AS tax_usd,
	  CASE
	  WHEN os.credit IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.credit/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.credit/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.credit/fx_rate_usd_URU
	  ELSE os.credit
	  END AS credit_usd,						 
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month,sum(credit_usd)as credit_usd
from order_line_Sale_dollars
group by Year, Month
order by Year, Month 
-- - Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito
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
	  CASE
	  WHEN os.tax IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.tax/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.tax/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.tax/fx_rate_usd_URU
	  ELSE os.tax
	  END AS tax_usd,
	  CASE
	  WHEN os.credit IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.credit/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.credit/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.credit/fx_rate_usd_URU
	  ELSE os.credit
	  END AS credit_usd,						 
	  (c.product_cost_usd*os.quantity) as costo_linea
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select extract(year from date)as Year,extract(month from date)as Month,order_number,sum(Ventas_en_dolares-Descuento_en_dolares+tax_usd-credit_usd)as amount_paid_usd
from order_line_Sale_dollars
group by Year, Month,order_number
order by Year, Month 
-- Supply Chain (USD)
-- - Costo de inventario promedio por tienda
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)

select extract(year from osd.date)as Year,extract(month from osd.date)as Month,osd.store, sum(costo_inv_prom) as inventory_cost_usd
from order_line_Sale_dollars osd
left join inventory_dollars id on osd.date=id.date and osd.store=id.store_id and osd.product=id.item_id and osd.category=id.category
group by  Year, Month,osd.store
-- - Costo del stock de productos que no se vendieron por tienda
with inventory_dollars as (SELECT date,store_id,item_id,category,
	  (c.product_cost_usd*(i.initial+i.final)/2) as costo_inv_prom
from stg.inventory i
left join stg.cost c on c.product_code=i.item_id
left join stg.product_master pm on pm.product_code=c.product_code),
order_line_Sale_dollars as (SELECT cast(date_trunc('month',os.date) as date) as date,store,product,category,sale,
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)

select extract(year from id.date)as Year,extract(month from id.date)as Month,id.store_id,id.item_id,
 sum(costo_inv_prom) as inventory_cost_usd
from inventory_dollars id
left join order_line_Sale_dollars osd on osd.date=id.date and osd.store=id.store_id and osd.product=id.item_id and osd.category=id.category
where osd.sale is NULL
group by Year, Month, id.store_id, osd.product, id.item_id
-- - Cantidad y costo de devoluciones
with return_movements_customers as (select * 
from stg.return_movements
where from_location='Customer'),
order_line_Sale_dollars as (SELECT cast(date_trunc('month',os.date) as date) as date,order_number,product,quantity,sale,
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
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.product_master pm on pm.product_code=os.product)
SELECT extract(year from os.date)as Year,extract(month from os.date)as Month, sum(rm.quantity) as quantity, sum(rm.quantity*(Ventas_en_dolares/os.quantity)) as returned_sales_usd
from order_line_Sale_dollars os
left join return_movements_customers rm on os.order_number= rm.order_id and os.product=rm.item and date_trunc('month',os.date)::date=date_trunc('month',rm.date)::date
group by Year, Month

-- Tiendas
-- - Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra
with super_store_and_market_count as(SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
FROM stg.super_store_count sc
UNION ALL
SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
FROM stg.market_count mc),
ordenes_generadas as (Select extract(year from os.date)as Year, extract(month from os.date)as Month,count(distinct os.order_number) as Cantidad_de_ordenes_generadas
from stg.order_line_sale os
group by Year, Month),
Cantidad_gente_entra as (Select extract(year from smc.date)as Year, extract(month from smc.date)as Month, sum(traffic) as Cantidad_de_gente_que_entra
from super_store_and_market_count smc 
group by Year, Month
order by Year, Month)
Select og.year,og.month, ce.cantidad_de_gente_que_entra, og.cantidad_de_ordenes_generadas, (cast(og.cantidad_de_ordenes_generadas as numeric) /cast(ce.cantidad_de_gente_que_entra as numeric))as cvr
from Cantidad_gente_entra ce
left join ordenes_generadas og on og.year=ce.year and og.month=ce.month

