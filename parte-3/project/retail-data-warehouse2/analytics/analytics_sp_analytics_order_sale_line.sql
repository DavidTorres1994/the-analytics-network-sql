create table if not exists  analytics.order_sale_line2(date date, product_code varchar(255),store smallint,order_number varchar(255),country varchar(100),
											province varchar(100),store_name varchar(255),category varchar(255),subcategory varchar(255),subsubcategory varchar(255),
											  supplier_name varchar(255),month date,month_label text, year date,fiscal_year date,fiscal_quarter text,
											  is_walkout boolean, quantity integer,quantity_returned integer,amount_returned_usd numeric,receive_location varchar(100),
											  final_location varchar(100), gross_sales numeric,gross_sales_usd numeric,other_income numeric,shrinkage_cost numeric,
											  promotion numeric,promotion_usd numeric, credit numeric, credit_usd numeric,tax numeric, tax_usd numeric,sale_line_cost_usd numeric)


create or replace procedure analytics.sp_analytics_order_sale_line()
language plpgsql as $$
begin

truncate table analytics.order_sale_line2; 
insert into analytics.order_sale_line2
select date , product_code,store ,order_number,country,province,store_name ,category,subcategory ,subsubcategory,
	supplier_name ,month ,month_label, year,fiscal_year,fiscal_quarter,is_walkout, quantity,quantity_returned,amount_returned_usd,receive_location,
	final_location, gross_sales,gross_sales_usd,other_income,shrinkage_cost,promotion,promotion_usd,credit,credit_usd,tax,tax_usd,sale_line_cost_usd 
from		   
(with stg_returns as (
select distinct on (order_id, item)
		order_id, 
		item, 
		first_value(from_location) over (partition by order_id, item order by movement_id asc) as receive_location,
		last_value(to_location) over (partition by order_id, item) as final_location,
		date, 
		quantity
    from fct.return_movements r),
ohter_incomes as (select os.date,os.order_number as order_number2,os.product,
brand,				  
		CASE 
		  WHEN extract(Year from os.date)=2022 then 20000*1.00/count(*) over(partition by extract(year from os.date))
		  WHEN extract(Year from os.date)=2023 then 5000*1.00/count(*) over(partition by extract(year from os.date))		
	      END AS Other_income
from fct.order_line_sale os
left join dim.product_master pm on pm.product_code=os.product
where brand='Phillips'  
),
stg_shrinkage as (
select
ols.order_number,
ols.product,
ols.store,
ols.date,
sh.quantity,
sh.quantity*1.00/count(*)over(partition by ols.product,ols.store,EXTRACT(YEAR FROM ols.date))AS q_distribution,
sh.quantity*1.00/count(*)over(partition by ols.product,ols.store,EXTRACT(YEAR FROM ols.date))*c.cost_usd as shrinkage_cost	
from fct.order_line_sale ols
left join stg.shrinkage sh on CAST(sh.year AS INTEGER)=EXTRACT(YEAR FROM ols.date) and sh.store_id=ols.store and sh.item_id=ols.product
left join dim.cost c on c.product_id=ols.product
 )
select os.date,
pm.product_code,
os.store,
os.order_number,
country,
province,
sm.name as store_name,
category,
subcategory,
subsubcategory,
s.name as supplier_name, 
d.month,
month_label,
year,
fiscal_year,
fiscal_quarter_label as fiscal_quarter,
is_walkout,
os.quantity,
rm.quantity as quantity_returned,
   etl.convert_currency_usd((os.sale*rm.quantity)/os.quantity,os.date,os.currency)AS amount_returned_usd,
  --CASE
    --      WHEN currency='ARS' THEN (os.sale*rm.quantity/mf.fx_rate_usd_peso)/os.quantity
	--	  WHEN currency='URU' THEN (os.sale*rm.quantity/mf.fx_rate_usd_uru)/os.quantity
     --     WHEN currency='EUR' THEN (os.sale*rm.quantity/mf.fx_rate_usd_eur)/os.quantity
     --     ELSE (os.sale*rm.quantity)/os.quantity
	--	  END AS amount_returned_usd,
receive_location,
final_location,
          os.sale as gross_sales,
      etl.convert_currency_usd(os.sale,os.date,os.currency)AS gross_sales_usd,
     --   CASE
     --   WHEN currency='ARS' THEN os.sale/mf.fx_rate_usd_peso
	 --	  WHEN currency='URU' THEN os.sale/mf.fx_rate_usd_uru
     --   WHEN currency='EUR' THEN os.sale/mf.fx_rate_usd_eur
     --   ELSE os.sale
	 --	  END AS gross_sales_usd,
		  other_income,
		  shrinkage_cost,
		  os.promotion,
          etl.convert_currency_usd(coalesce(os.promotion,0),os.date,os.currency) AS promotion_usd,
	--	  CASE
    --      WHEN currency='ARS' THEN coalesce(os.promotion,0)/mf.fx_rate_usd_peso
	--	  WHEN currency='URU' THEN coalesce(os.promotion,0)/mf.fx_rate_usd_uru
    --      WHEN currency='EUR' THEN coalesce(os.promotion,0)/mf.fx_rate_usd_eur
    --      ELSE os.promotion
	--	  END AS promotion_usd,
		  os.credit,
          etl.convert_currency_usd(coalesce(os.credit,0),os.date,os.currency) AS credit_usd,
	--	  CASE
    --      WHEN currency='ARS' THEN coalesce(os.credit,0)/mf.fx_rate_usd_peso
	--	  WHEN currency='URU' THEN coalesce(os.credit,0)/mf.fx_rate_usd_uru
    --      WHEN currency='EUR' THEN coalesce(os.credit,0)/mf.fx_rate_usd_eur
    --      ELSE os.credit
	--	  END AS credit_usd,
		  os.tax,
          etl.convert_currency_usd(coalesce(os.tax,0),os.date,os.currency) AS tax_usd,
	--	  CASE
    --      WHEN currency='ARS' THEN coalesce(os.tax,0)/mf.fx_rate_usd_peso
	--	  WHEN currency='URU' THEN coalesce(os.tax,0)/mf.fx_rate_usd_uru
    --      WHEN currency='EUR' THEN coalesce(os.tax,0)/mf.fx_rate_usd_eur
    --      ELSE os.tax
	--	  END AS tax_usd,
							 
		  (c.cost_usd*os.quantity)as sale_line_cost_usd
from stg.order_line_sale os
left join fct.fx_rate mf on date_trunc('month',os.date)=date_trunc('month',mf.month)
left join dim.cost c on c.product_id=os.product
left join dim.store_master sm on sm.store_id=os.store
left join dim.product_master pm on pm.product_code=os.product
left join dim.date d on d.date=os.date
left join dim.supplier s on s.product_id=os.product
left join ohter_incomes oi2 on oi2.order_number2=os.order_number and oi2.product=os.product			   
left join stg_returns rm on rm.order_id=os.order_number and rm.item=os.product and rm.date=os.date
left join stg_shrinkage shr on shr.order_number= os.order_number and shr.product= os.product
where is_primary = 'True' );  

end;
$$;
call analytics.sp_analytics_order_sale_line()
