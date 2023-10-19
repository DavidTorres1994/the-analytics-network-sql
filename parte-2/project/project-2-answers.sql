create view viz.order_sale_line as
 -- select 
;
with inventory_dollars as (SELECT date_trunc('month',i.date)as año_mes,i.store_id, i.item_id,
	  c.product_cost_usd*(i.initial+i.final)/2 as costo_inv_prom
from stg.inventory i
left join stg.cost c on c.product_code=i.item_id
left join stg.product_master pm on pm.product_code=c.product_code
order by date_trunc('month',i.date)),
order_line_sale_dollars AS (
         SELECT os.order_number,
            os.product,
            os.quantity,
            pm.category,
            sm.country,
	        os.store,
            date_trunc('month'::text, os.date::timestamp with time zone)::date AS date,
                CASE
                    WHEN os.currency::text = 'EUR'::text THEN os.sale / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.sale / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.sale / mr.fx_rate_usd_uru
                    ELSE os.sale
                END AS sale_usd,
                CASE
                    WHEN os.promotion IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.promotion / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.promotion / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.promotion / mr.fx_rate_usd_uru
                    ELSE os.promotion
                END AS promotion_usd,
                CASE
                    WHEN os.tax IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.tax / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.tax / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.tax / mr.fx_rate_usd_uru
                    ELSE os.tax
                END AS tax_usd,
                CASE
                    WHEN os.credit IS NULL THEN 0::numeric
                    WHEN os.currency::text = 'EUR'::text THEN os.credit / mr.fx_rate_usd_eur
                    WHEN os.currency::text = 'ARS'::text THEN os.credit / mr.fx_rate_usd_peso
                    WHEN os.currency::text = 'URU'::text THEN os.credit / mr.fx_rate_usd_uru
                    ELSE os.credit
                END AS credit_usd,
            c.product_cost_usd * os.quantity::numeric AS line_cost_usd
           FROM stg.order_line_sale os
             LEFT JOIN stg.monthly_average_fx_rate mr ON date_trunc('month'::text, mr.month::timestamp with time zone)::date = date_trunc('month'::text, os.date::timestamp with time zone)::date
             LEFT JOIN stg.cost c ON c.product_code::text = os.product::text
             LEFT JOIN stg.store_master sm ON sm.store_id = os.store
             LEFT JOIN stg.product_master pm ON pm.product_code::text = os.product::text
        )
select  *
from inventory_dollars id
left join order_line_Sale_dollars osd on osd.date=id.año_mes and id.store_id=osd.store and id.item_id=osd.product
