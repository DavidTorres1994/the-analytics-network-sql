create view viz.order_sale_line as
with inventory_dollars as (SELECT date_trunc('month',i.date)as año_mes,i.store_id, i.item_id,
	 sum(c.product_cost_usd*(i.initial+i.final)/2) as costo_inv_prom
from stg.inventory i
left join stg.cost c on c.product_code=i.item_id
--left join stg.product_master pm on pm.product_code=c.product_code
group by date_trunc('month',i.date),i.item_id,i.store_id					   
order by date_trunc('month',i.date)),
shrinkage_dollars as (SELECT TO_DATE(sh.year || '-01-01','YYYY-MM-DD')as Year1,sh.store_id, sh.item_id,
	 sum(c.product_cost_usd*sh.quantity) as costo_add
from stg.shrinkage sh
left join stg.cost c on c.product_code=sh.item_id
group by TO_DATE(sh.year || '-01-01','YYYY-MM-DD'),sh.item_id,sh.store_id					   
order by TO_DATE(sh.year || '-01-01','YYYY-MM-DD')),
order_line_sale_dollars AS (
        SELECT 
            os.product,
            pm.name as product_name,
	        os.quantity as quantity,
            pm.category,
	        pm.subcategory,
	        pm.subsubcategory,
	        s.name as supplier,
            sm.country,
	        sm.province,
	        sm.store_id as tienda,
	        sm.name as store_name,
	        os.store,
            date_trunc('month'::text, os.date::timestamp with time zone)::date AS date1,
	        os.order_number,
            CASE
				    WHEN os.currency::text = 'EUR'::text  THEN os.sale / mr.fx_rate_usd_eur				
				    WHEN os.currency::text = 'ARS'::text THEN os.sale / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.sale / mr.fx_rate_usd_uru
				    
                    ELSE os.sale
                END AS gross_sales_usd,
	          os.sale as gross_sales,
              CASE
                    WHEN os.promotion IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.promotion / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.promotion / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.promotion / mr.fx_rate_usd_uru
                    ELSE os.promotion
                END AS promotion_usd,
	            os.promotion as promotion,
                CASE
                    WHEN os.tax IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.tax / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.tax / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.tax / mr.fx_rate_usd_uru
                    ELSE os.tax
                END AS tax_usd,
	            os.tax as tax,
                CASE
                    WHEN os.credit IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.credit / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.credit / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.credit / mr.fx_rate_usd_uru
                    ELSE os.credit
                END AS credit_usd,
	           os.credit as credit,
            c.product_cost_usd * os.quantity::numeric AS sale_line_cost_usd
           FROM stg.order_line_sale os
             LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month'::text, mr.month::timestamp with time zone)::date = date_trunc('month'::text, os.date::timestamp with time zone)::date
             LEFT JOIN stg.cost c ON c.product_code::text = os.product::text
             LEFT JOIN stg.store_master sm ON sm.store_id = os.store
             LEFT JOIN stg.product_master pm ON pm.product_code::text = os.product::text
		     LEFT JOIN stg.supplier s ON pm.product_code=s.product_id
	        where is_primary = 'True'
			/*group by os.product,pm.name
	       ,pm.category, pm.subcategory,
	        pm.subsubcategory,
	        s.name,sm.country,sm.province,sm.store_id, sm.name, os.store,
            date_trunc('month'::text, os.date::timestamp with time zone)::date,
			os.order_number */
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
sale_by_product as (select osd.date1 as fecha, *
from order_line_Sale_dollars osd
left join inventory_dollars id on osd.date1=id.año_mes and id.store_id=osd.store and id.item_id=osd.product
left join shrinkage_dollars sd on date_trunc('year', osd.date1)=sd.year1 and sd.store_id=osd.store and sd.item_id=osd.product
left join Calendar cal on cal.date2=osd.date1),
return_movements_customers as (select * 
from stg.return_movements
where from_location='Customer'),
order_line_sale as(
select *, date_trunc('month',date) AS mes
from stg.order_line_sale),							 
return_movements_by_month as (SELECT os.mes,os.product as product2 ,sum(rm.quantity) as return_quantity--, sum(os.quantity) as quantity
from order_line_sale os
left join return_movements_customers rm on os.order_number= rm.order_id and os.product=rm.item and date_trunc('month',os.mes)::date=date_trunc('month',rm.date)::date
group by os.mes,os.product),
Cantidad_gente_entra as (Select date_trunc('Month',smc.date)as año_mes1,store_id, sum(traffic) as Cantidad_de_gente_que_entra
from stg.vw_store_traffic smc 
group by date_trunc('Month',smc.date),store_id),
phillips_products_2022 AS (
  SELECT 
    *,
    CASE 
      WHEN olsd.product_name LIKE '%PHILIPS%' and EXTRACT(YEAR FROM olsd.año_mes)='2022' THEN 1
      ELSE 0
    END AS is_philips
  FROM sale_by_product olsd
),
philips_count1 AS (
  SELECT 
    EXTRACT(YEAR FROM pp.año_mes) as año,
    SUM(is_philips) AS count_philips
  FROM phillips_products_2022 pp
  GROUP BY año
),
phillips_products_2023 AS (
  SELECT 
    *,
    CASE 
      WHEN olsd.product_name LIKE '%PHILIPS%' and EXTRACT(YEAR FROM olsd.año_mes)='2023' THEN 1
      ELSE 0
    END AS is_philips
  FROM sale_by_product olsd
),
philips_count2 AS (
  SELECT 
    EXTRACT(YEAR FROM pp.año_mes) as año2,
    SUM(is_philips) AS count_philips2
  FROM phillips_products_2023 pp
  GROUP BY año2
),
sale_by_product2 as (
select spo.date1,dia_de_la_semana,month_label,year,fiscal_year_label,fiscal_quarter_label,order_number
,product,product_name,category,subcategory,subsubcategory,supplier,tienda,store_name
,country,province, gross_sales_usd,gross_sales,case  
                   WHEN product_name like '%PHILIPS%' and EXTRACT(YEAR FROM spo.date1)='2022' THEN gross_sales_usd+(20000/pc.count_philips)
				   WHEN product_name like '%PHILIPS%' and EXTRACT(YEAR FROM spo.date1)='2023' THEN gross_sales_usd+(5000/pc2.count_philips2)
				   else gross_sales_usd
				   end as sale_usd_plus_other_income
, promotion_usd,promotion, tax_usd,tax, credit_usd,credit
, (gross_sales_usd-coalesce(promotion_usd,0)) as net_sales_usd,(gross_sales- coalesce(promotion,0)) as net_sales, (gross_sales_usd-promotion_usd+tax_usd-credit_usd)as amount_paid_usd,(gross_sales-promotion+tax-credit)as amount_paid
,(gross_sales_usd-promotion_usd)/(costo_inv_prom)as roi, sale_line_cost_usd, (costo_add*1.00/(count(spo.*) over(partition by date_trunc('Year',spo.date1),product,tienda)))as other_cost, (gross_sales_usd-sale_line_cost_usd)AS gross_margin_usd,
 /*cant_order_number as cantidad_de_ordenes_generadas,*/
quantity,(rmm.return_quantity*1.00/(count(rmm.*) over(partition by rmm.mes,product2))) as return_quantity,(gross_sales_usd/quantity) * (rmm.return_quantity*1.00/(count(rmm.*) over(partition by rmm.mes,product2))) as amount_returned_usd,
(cantidad_de_gente_que_entra*1.00/(count(cge.*) over(partition by cge.año_mes1,cge.store_id))) as cantidad_de_gente_que_entra
from sale_by_product spo
LEFT JOIN philips_count1 pc ON EXTRACT(YEAR FROM spo.date1) = pc.año
LEFT JOIN philips_count2 pc2 ON EXTRACT(YEAR FROM spo.date1) = pc2.año2
left join return_movements_by_month rmm on rmm.mes=spo.date1 and rmm.product2=spo.product
left join Cantidad_gente_entra cge on cge.año_mes1=spo.date1 and cge.store_id=spo.tienda)
select *, (sale_usd_plus_other_income-sale_line_cost_usd-other_cost) as AGM
from sale_by_product2
