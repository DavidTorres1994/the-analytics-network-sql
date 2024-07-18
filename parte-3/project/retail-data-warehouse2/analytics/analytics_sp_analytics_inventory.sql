create table if not exists analytics.inventory2(date date, product_code varchar(255),store smallint,order_number varchar(255),country varchar(100),
											province varchar(100),store_name varchar(255),category varchar(255),subcategory varchar(255),subsubcategory varchar(255),
											  supplier_name varchar(255),month date,month_label text, year date,fiscal_year date,fiscal_quarter text,Avg_Inv integer,Cost_Avg_Inv numeric)
											  
create or replace procedure analytics.sp_analytics_inventory()
language plpgsql as $$
begin

truncate table analytics.inventory2; 
insert into analytics.inventory2
select date , product_code,store ,order_number,country,province,store_name ,category,subcategory ,subsubcategory,
	supplier_name ,month ,month_label, year,fiscal_year,fiscal_quarter, Avg_Inv,Cost_Avg_Inv
from		   
(
select i.date,
i.item_id as product_code,
i.store_id as store,
o.order_number,
sm.country,
sm.province,
sm.name as store_name,
pm.category,
pm.subcategory,
pm.subsubcategory,
s.name as supplier_name, 
d.month,
d.month_label,
d.year,
d.fiscal_year,
d.fiscal_quarter_label as fiscal_quarter,
(i.initial+i.final)/2 as Avg_Inv,
((i.initial+i.final)*1.00/2)*c.cost_usd as Cost_Avg_Inv				 

from fct.inventory i
left join fct.order_line_sale o on o.date=i.date and o.store=i.store_id and o.product=i.item_id
left join dim.cost c on c.product_id=i.item_id
left join dim.store_master sm on sm.store_id=i.store_id
left join dim.product_master pm on pm.product_code=i.item_id
left join dim.date d on d.date=i.date
left join dim.supplier s on s.product_id=i.item_id
where s.is_primary = 'True');
  

end;
$$;
call analytics.sp_analytics_inventory()

CREATE OR REPLACE PROCEDURE analytics.sp_test_pk_analytics_inventory()
LANGUAGE plpgsql as $$

BEGIN 
IF EXISTS (
        SELECT date, store, product_code,count(1)
        FROM analytics.inventory2
        GROUP BY 1, 2,3
        HAVING count(1) > 1
    ) THEN
        RAISE EXCEPTION 'Duplicados encontrados en inventory';
    END IF;

  
  END;
$$;

call analytics.sp_test_pk_analytics_inventory()
