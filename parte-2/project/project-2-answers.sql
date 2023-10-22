create view viz.order_sale_line as
 -- select 
with inventory_dollars as (SELECT date_trunc('month',i.date)as año_mes,i.store_id, i.item_id,
	 sum(c.product_cost_usd*(i.initial+i.final)/2) as costo_inv_prom
from stg.inventory i
left join stg.cost c on c.product_code=i.item_id
left join stg.product_master pm on pm.product_code=c.product_code
group by date_trunc('month',i.date),i.item_id,i.store_id					   
order by date_trunc('month',i.date)),
order_line_sale_dollars AS (
         SELECT 
            os.product,
           -- os.quantity,
            pm.category,
	        pm.subcategory,
	        pm.subsubcategory,
	        s.name as supplier,
            sm.country,
	        sm.province,
	        sm.name as store_name,
	        os.store,
            date_trunc('month'::text, os.date::timestamp with time zone)::date AS date,
	        count(distinct os.order_number) as cant_order_number,
            sum(CASE
                    WHEN os.currency::text = 'EUR'::text THEN os.sale / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.sale / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.sale / mr.fx_rate_usd_uru
                    ELSE os.sale
                END) AS sale_usd,
              sum(CASE
                    WHEN os.promotion IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.promotion / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.promotion / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.promotion / mr.fx_rate_usd_uru
                    ELSE os.promotion
                END) AS promotion_usd,
                sum(CASE
                    WHEN os.tax IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.tax / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.tax / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.tax / mr.fx_rate_usd_uru
                    ELSE os.tax
                END) AS tax_usd,
                sum(CASE
                    WHEN os.credit IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.credit / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.credit / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.credit / mr.fx_rate_usd_uru
                    ELSE os.credit
                END) AS credit_usd,
            sum(c.product_cost_usd * os.quantity::numeric) AS line_cost_usd
           FROM stg.order_line_sale os
             LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month'::text, mr.month::timestamp with time zone)::date = date_trunc('month'::text, os.date::timestamp with time zone)::date
             LEFT JOIN stg.cost c ON c.product_code::text = os.product::text
             LEFT JOIN stg.store_master sm ON sm.store_id = os.store
             LEFT JOIN stg.product_master pm ON pm.product_code::text = os.product::text
		     LEFT JOIN stg.supplier s ON pm.product_code=s.product_id
	        where is_primary = 'True'
			group by os.product
	       ,pm.category, pm.subcategory,
	        pm.subsubcategory,
	        s.name,sm.country,sm.province, sm.name, os.store,
            date_trunc('month'::text, os.date::timestamp with time zone)::date
        ),
Calendar AS (SELECT 
  TO_CHAR(date, 'yyyymmdd')::integer AS date_id,
  CAST(date AS date) AS date2,
  CAST(date_trunc('month', date) AS date) AS month,
  CAST(date_trunc('year', date) AS date) AS year,
  TO_CHAR(CAST(date_trunc('day', date) AS date), 'Day') AS Dia_de_la_semana,
  CASE  
    WHEN EXTRACT(DOW FROM date) IN (0, 6)  THEN TRUE
    ELSE FALSE
  END AS is_weekend,
  TO_CHAR(CAST(date_trunc('month', date) AS date), 'Month') AS month_label,
          (CASE 
            WHEN EXTRACT(MONTH FROM date) < 2 THEN EXTRACT(YEAR FROM date) - 1 
            ELSE EXTRACT(YEAR FROM date) END || '-02-01')::date AS fiscal_year,
		CONCAT('FY',CASE 
            WHEN EXTRACT(MONTH FROM date) < 2 THEN EXTRACT(YEAR FROM date) - 1 
            ELSE EXTRACT(YEAR FROM date) END) AS fiscal_year_label,
		CASE 
          WHEN EXTRACT(MONTH FROM date) BETWEEN 2 AND 4 THEN 'Q1'
          WHEN EXTRACT(MONTH FROM date) BETWEEN 5 AND 7 THEN 'Q2'
          WHEN EXTRACT(MONTH FROM date) BETWEEN 8 AND 10 THEN 'Q3'
          ELSE 'Q4'	
		END AS fiscal_quarter_label,
		CAST( date - interval '1 year' AS date)::date AS date_ly
		
FROM (SELECT CAST('2022-01-01' AS date) + (n || 'day')::interval AS date
      FROM generate_series(0, 730) n) dd),		
sale_by_product as (select osd.date as fecha, *
from order_line_Sale_dollars osd
left join inventory_dollars id on osd.date=id.año_mes and id.store_id=osd.store and id.item_id=osd.product
left join Calendar cal on cal.date2=osd.date),
return_movements_customers as (select * 
from stg.return_movements
where from_location='Customer'),
order_line_sale as(
select *, date_trunc('month',date) AS mes
from stg.order_line_sale),							 
return_movements_by_month as (SELECT os.mes,os.product as product2 ,sum(rm.quantity) as quantity
from order_line_sale os
left join return_movements_customers rm on os.order_number= rm.order_id and os.product=rm.item and date_trunc('month',os.mes)::date=date_trunc('month',rm.date)::date
group by os.mes,os.product)--,
select año_mes,dia_de_la_semana,month_label,year,fiscal_year_label,fiscal_quarter_label,product,category,subcategory,subsubcategory,supplier,store_name,country,province,sale_usd, promotion_usd, tax_usd, credit_usd
, (sale_usd-promotion_usd) as net_sales_usd, (sale_usd-promotion_usd+tax_usd-credit_usd)as amount_paid_usd
,(sale_usd-promotion_usd)/(costo_inv_prom)as roi, line_cost_usd, (sale_usd-promotion_usd-line_cost_usd)AS margin_usd,
cant_order_number,(quantity*1.00/(count(rmm.*) over(partition by rmm.mes,product2))) as return_quantity
from sale_by_product spo
left join return_movements_by_month rmm on rmm.mes=spo.año_mes and rmm.product2=spo.product

/*super_store_and_market_count as(SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
FROM stg.super_store_count sc
UNION ALL
SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
FROM stg.market_count mc),
ordenes_generadas as (Select date_trunc('Month',spo.año_mes)as año_mes,sum(cant_order_number) as Cantidad_de_ordenes_generadas
from sale_by_product spo
group by date_trunc('Month',spo.año_mes)),
Cantidad_gente_entra as (Select date_trunc('Month',smc.date)as año_mes, sum(traffic) as Cantidad_de_gente_que_entra
from super_store_and_market_count smc 
group by date_trunc('Month',smc.date))
Select og.año_mes, ce.cantidad_de_gente_que_entra, og.cantidad_de_ordenes_generadas, (cast(og.cantidad_de_ordenes_generadas as numeric) /cast(ce.cantidad_de_gente_que_entra as numeric))as cvr
from Cantidad_gente_entra ce
left join ordenes_generadas og on og.año_mes=ce.año_mes 
order by og.año_mes desc
*/
