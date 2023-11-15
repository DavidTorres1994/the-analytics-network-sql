CREATE OR REPLACE PROCEDURE etl.sp_analytics()
LANGUAGE plpgsql as $$
BEGIN 
   DROP TABLE IF EXISTS analytics.order_sale_line;
   CREATE TABLE IF NOT EXISTS analytics.order_sale_line as
   SELECT *
   FROM (
   with fct_agm as (
   select 
     ols.order_number
    ,ols.product
	--,ols.date
    --,20000 as adjustment_usd
   -- ,count(1) over(partition by extract(year from ols.date)) as nrows
    ,case when extract(year from ols.date) = 2022 
			then 20000*1.00/(count(1) over(partition by extract(year from ols.date)))*1.00 
		  when extract(year from ols.date) = 2023 
			then 5000*1.00/(count(1) over(partition by extract(year from ols.date)))*1.00 
	end as distributed_adjustment
    from fct.order_line_sale ols
    left join dim.product_master pm on pm.product_code = ols.product
    where lower(pm.name) like '%philips%'
	--and extract(year from ols.date) = 2022
    ), 
	stg_shrinkage as (
	select 
	ols.order_number,
	ols.product,
	ols.store,
	ols.date, 
	s.quantity,
	s.quantity * 1.00 / count(1) over(partition by ols.product, ols.store, extract(year from ols.date)) *1.00 as atribution,
	(s.quantity * 1.00 / count(1) over(partition by ols.product, ols.store, extract(year from ols.date)) *1.00) * cos.cost_usd as shrinkage_cost,
	cos.cost_usd
    from fct.order_line_sale ols 
    left join stg.shrinkage s 
	on ols.store = s.store_id
	and ols.product = s.item_id
	and extract(year from ols.date) = CAST(s.year AS NUMERIC)
    left join dim.cost cos
	on ols.product = cos.product_id
	), 
	fct_returns as (
	select distinct on (order_id, item)
		order_id, 
		item, 
		first_value(from_location) over (partition by order_id, item order by movement_id asc) as receive_location,
		last_value(to_location) over (partition by order_id, item) as final_location,
		date, 
		quantity
    from fct.return_movements rm
    ), 
	fct_sales as (
    select 
    ols.order_number, 
    ols.date,
    ols.product as product_code, 
    pm.category,
    pm.subcategory,
    pm.subsubcategory,
    pm.material,
   sup.name as supplier_name,
    ols.store,
    sm.name as store_name,
    sm.country,
    sm.province, 
    sm.city,
    d.month,
    d.month_label,
    d.fiscal_year,
    d.fiscal_year_label,
    d.fiscal_quarter_label,
    ols.is_walkout,
    ols.quantity,
    ols.sale as gross_sales,
    case when ols.currency = 'ARS' then ols.sale/ma.fx_rate_usd_peso 
         when ols.currency = 'EUR' then ols.sale/ma.fx_rate_usd_eur
         when ols.currency = 'URU' then ols.sale/ma.fx_rate_usd_uru
         end as gross_sales_usd,
    ols.promotion,
    case when ols.currency = 'ARS' then ols.promotion/ma.fx_rate_usd_peso 
         when ols.currency = 'EUR' then ols.promotion/ma.fx_rate_usd_eur
         when ols.currency = 'URU' then ols.promotion/ma.fx_rate_usd_uru
         end as promotion_usd,
    ols.tax,
    case when ols.currency = 'ARS' then ols.tax/ma.fx_rate_usd_peso 
         when ols.currency = 'EUR' then ols.tax/ma.fx_rate_usd_eur
         when ols.currency = 'URU' then ols.tax/ma.fx_rate_usd_uru
         end as tax_usd,
    ols.credit,
         case when ols.currency = 'ARS' then ols.credit/ma.fx_rate_usd_peso 
         when ols.currency = 'EUR' then ols.credit/ma.fx_rate_usd_eur
         when ols.currency = 'URU' then ols.credit/ma.fx_rate_usd_uru
         end as credit_usd,
    cos.cost_usd * ols.quantity as sale_line_cost_usd, 
    agm.distributed_adjustment,
    shrinkage.shrinkage_cost,
    returns.quantity as quantity_returned,
    returns.receive_location,
    returns.final_location
    from fct.order_line_sale ols
    left join fct.fx_rate ma
	on extract(month from ols.date) = extract(month from ma.month) 
	and extract(year from ols.date) = extract(year from ma.month)
    left join dim.cost cos
	on ols.product = cos.product_id
    left join dim.product_master pm 
	on ols.product = pm.product_code
    left join dim.store_master sm 
	on sm.store_id = ols.store 
    left join dim.date d 
	on ols.date = d.date
    left join dim.supplier sup 
	on ols.product = sup.product_id
	and sup.is_primary = True
    left join fct_returns returns 
	on returns.order_id = ols.order_number 
	and returns.item = ols.product
    left join fct_agm agm 
	on ols.order_number = agm.order_number
	and ols.product = agm.product
    left join stg_shrinkage shrinkage
	on ols.order_number = shrinkage.order_number
	and ols.product = shrinkage.product
   )
   select 
   order_number, 
   date,
   product_code, 
   category,
   subcategory,
   subsubcategory,
   material,
   supplier_name,
   store,
   store_name,
   country,
   province, 
   city,
   month,
   month_label,
   fiscal_year,
   fiscal_year_label,
   fiscal_quarter_label,
   is_walkout,
   quantity,
   gross_sales,
   gross_sales_usd,
   promotion,
   promotion_usd,
   gross_sales - coalesce(promotion,0) as net_sales,
   gross_sales_usd - coalesce(promotion_usd,0) as net_sales_usd,
   tax,
   tax_usd,
   credit, 
   credit_usd,
   sale_line_cost_usd,
   gross_sales_usd - coalesce(promotion_usd,0) - sale_line_cost_usd as gross_margin_usd,
   gross_sales_usd 
  	- coalesce(promotion_usd,0) 
	- sale_line_cost_usd 
	+ coalesce(distributed_adjustment,0) 
	- coalesce(shrinkage_cost,0) 
	as adjusted_gross_margin_usd,
   quantity_returned,
   (gross_sales_usd/quantity) * quantity_returned as amount_returned_usd,
   receive_location,
   final_location
   from 
	fct_sales);
end;
 $$;

call etl.sp_analytics()
