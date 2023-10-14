-- ## Semana 3 - Parte A

-- 1.Crear una vista con el resultado del ejercicio donde unimos la cantidad de gente que ingresa a tienda usando los dos sistemas.(tablas market_count y super_store_count)
-- . Nombrar a la lista `stg.vw_store_traffic`
-- . Las columnas son `store_id`, `date`, `traffic`
create view stg.vw_store_traffic as
SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
FROM stg.super_store_count sc
UNION ALL
SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
FROM stg.market_count mc

-- 2. Recibimos otro archivo con ingresos a tiendas de meses anteriores. Subir el archivo a stg.super_store_count_aug y agregarlo a la vista del ejercicio anterior. Cual hubiese sido la diferencia si hubiesemos tenido una tabla? (contestar la ultima pregunta con un texto escrito en forma de comentario)

--la diferencia radica en que en la tabla los datos se guardarían en memoria, lo que significa que estarían disponibles aún cerrando sesión.
--Las vistas proporcionaría una representación temporal de los datos

-- 3. Crear una vista con el resultado del ejercicio del ejercicio de la Parte 1 donde calculamos el margen bruto en dolares. Agregarle la columna de ventas, promociones, creditos, impuestos y el costo en dolares para poder reutilizarla en un futuro. Responder con el codigo de creacion de la vista.
-- El nombre de la vista es stg.vw_order_line_sale_usd
-- Los nombres de las nuevas columnas son sale_usd, promotion_usd, credit_usd, tax_usd, y line_cost_usd
create view stg.vw_order_line_sale_usd as
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS sale_usd,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS promotion_usd,
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
	  (c.product_cost_usd*os.quantity) as line_cost_usd
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product)
select *, sale_usd-promotion_usd-line_cost_usd AS margin_usd
from order_line_Sale_dollars

-- 4. Generar una query que me sirva para verificar que el nivel de agregacion de la tabla de ventas (y de la vista) no se haya afectado. Recordas que es el nivel de agregacion/detalle? Lo vimos en la teoria de la parte 1! Nota: La orden M202307319089 parece tener un problema verdad? Lo vamos a solucionar mas adelante.
with stg_sales as(
select 
order_number,
product,
row_number() over(partition by order_number,product order by product asc) as rn
from stg.order_line_sale
)
select *
from stg_sales
where rn >1
--Para la vista
with stg_vw_sales as(
select 
order_number,
product,
row_number() over(partition by order_number,product order by product asc) as rn
from stg.vw_order_line_sale_usd
)
select *
from stg_vw_sales
where rn >1
-- 5. Calcular el margen bruto a nivel Subcategoria de producto. Usar la vista creada stg.vw_order_line_sale_usd. La columna de margen se llama margin_usd
select pm.subcategory, sum(margin_usd)as margin_usd
from stg.vw_order_line_sale_usd vwos
left join stg.product_master pm on vwos.product=pm.product_code
group by pm.subcategory
-- 6. Calcular la contribucion de las ventas brutas de cada producto al total de la orden.
with total_sale_usd_by_order_number as(
select order_number,sum(sale_usd)as sale_usd_by_order
from stg.vw_order_line_sale_usd vwos
group by order_number
order by order_number),
total_sale_usd_by_order_number_and_product as(
select order_number, product,sum(sale_usd)as sale_usd
from stg.vw_order_line_sale_usd vwos
group by order_number,product
order by order_number)
select top.*,ot.sale_usd_by_order, ((top.sale_usd)/(ot.sale_usd_by_order))as contri_usd_sale
from total_sale_usd_by_order_number_and_product top
left join total_sale_usd_by_order_number ot on ot.order_number=top.order_number
order by top.order_number	
-- 7. Calcular las ventas por proveedor, para eso cargar la tabla de proveedores por producto. Agregar el nombre el proveedor en la vista del punto stg.vw_order_line_sale_usd. El nombre de la nueva tabla es stg.suppliers
create view stg.vw_order_line_sale_usd as
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS sale_usd,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS promotion_usd,
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
	  (c.product_cost_usd*os.quantity) as line_cost_usd,
	s.name						 
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.supplier s on os.product=s.product_id
where s.is_primary=true)
select *, sale_usd-promotion_usd-line_cost_usd AS margin_usd
from order_line_Sale_dollars
--Ventas por proveedor
select name as supplier, sum(sale_usd) as sale_usd
from stg.vw_order_line_sale_usd
group by supplier

-- 8. Verificar que el nivel de detalle de la vista stg.vw_order_line_sale_usd no se haya modificado, en caso contrario que se deberia ajustar? Que decision tomarias para que no se genereren duplicados?
    -- - Se pide correr la query de validacion.
    -- - Modificar la query de creacion de stg.vw_order_line_sale_usd  para que no genere duplicacion de las filas. 
    -- - Explicar brevemente (con palabras escrito tipo comentario) que es lo que sucedia.
--Como en la tabla de "supplier", un producto puede estar relacionado con mas de un proveedor, se opta por poner la condición "s.is_primary=true"
--que permite obtener en la tabla "supplier" un producto y un solo proveedor, de esa manera al hacer left join entre la tabla ventas y 
--proveedores ya no se genera duplicados
-- ## Semana 3 - Parte B

-- 1. Calcular el porcentaje de valores null de la tabla stg.order_line_sale para la columna creditos y descuentos. (porcentaje de nulls en cada columna)
with null_sale as(
select order_number, product,case when credit IS NULL then 1 else 0 end as Credit_null,
	case when promotion IS NULL then 1 else 0 end as Promotion_null
from stg.order_line_sale)

select 
(sum(Credit_null)*1.00/count(*)*1.00) as porcent_total_credit_null,
(sum(Promotion_null)*1.00/count(*)*1.00) as procent_total_promotion_null
from null_sale
-- 2. La columna is_walkout se refiere a los clientes que llegaron a la tienda y se fueron con el producto en la mano (es decia habia stock disponible). Responder en una misma query:
   --  - Cuantas ordenes fueron walkout por tienda?
   --  - Cuantas ventas brutas en USD fueron walkout por tienda?
   --  - Cual es el porcentaje de las ventas brutas walkout sobre el total de ventas brutas por tienda?
--  - Cuantas ordenes fueron walkout por tienda?
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product,os.store, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS sale_usd,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS promotion_usd,
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
	  (c.product_cost_usd*os.quantity) as line_cost_usd,
    os.is_walkout,
	s.name						 
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.supplier s on os.product=s.product_id
where s.is_primary=true)   
select store, count(distinct order_number) as cantidad_ordenes
from order_line_Sale_dollars
where is_walkout='True'
group by store
--  - Cuantas ventas brutas en USD fueron walkout por tienda?
WITH order_line_Sale_dollars as (SELECT os.order_number,os.product,os.store, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS sale_usd,
	  CASE
	  WHEN os.promotion IS NULL THEN 0
	  WHEN currency = 'EUR' THEN os.promotion/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN os.promotion/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN os.promotion/fx_rate_usd_URU
	  ELSE os.promotion
	  END AS promotion_usd,
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
	  (c.product_cost_usd*os.quantity) as line_cost_usd,
    os.is_walkout,
	s.name						 
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.supplier s on os.product=s.product_id
where s.is_primary=true)   
select store, sum(sale_usd) as ventas_brutas
from order_line_Sale_dollars
where is_walkout='True'
group by store
 --  - Cual es el porcentaje de las ventas brutas walkout sobre el total de ventas brutas por tienda?
 WITH order_line_Sale_dollars as (SELECT os.store,
      sum(CASE
	 	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	      WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	      ELSE sale
	      END) AS sale_usd,
    os.is_walkout						 
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on date_trunc('month',mr.month)::date=date_trunc('month', os.date)::date
left join stg.cost c on c.product_code=os.product
left join stg.supplier s on os.product=s.product_id
where s.is_primary=true
group by os.store,os.is_walkout
order by os.store)  , 
total_Sales as (select store, sale_usd,is_walkout, sum(sale_usd) over(partition by store) as total_ventas_brutas
from order_line_Sale_dollars)
select *, (sale_usd/total_ventas_brutas) as porcentaje_de_ventas_brutas_walkout
from total_Sales
where is_walkout ='True'

-- 3. Siguiendo el nivel de detalle de la tabla ventas, hay una orden que no parece cumplirlo. Como identificarias duplicados utilizando una windows function? 
-- Tenes que generar una forma de excluir los casos duplicados, para este caso particular y a nivel general, si llegan mas ordenes con duplicaciones.
-- Identificar los duplicados.
-- Eliminar las filas duplicadas. Podes usar BEGIN transaction y luego rollback o commit para verificar que se haya hecho correctamente.
with stg_sales as(
select 
order_number,
product,
Row_number() over(partition by order_number,product order by product asc) as rn,
MIN(CTID)AS min_ctid
from stg.order_line_sale
group by order_number,product)
DELETE FROM stg.order_line_sale os
where CTID NOT IN (
	select min_ctid
	from stg_sales )
-- 4. Obtener las ventas totales en USD de productos que NO sean de la categoria TV NI esten en tiendas de Argentina. Modificar la vista stg.vw_order_line_sale_usd con todas las columnas necesarias. 
select product, sum(sale_usd)as ventas_totales
from stg.vw_order_line_sale_usd
where category <> 'TV' and country <> 'Argentina'
group by product
-- 5. El gerente de ventas quiere ver el total de unidades vendidas por dia junto con otra columna con la cantidad de unidades vendidas una semana atras y la diferencia entre ambos.Diferencia entre las ventas mas recientes y las mas antiguas para tratar de entender un crecimiento.
with ventas_día as (
	select cast(date_trunc('day',os.date)as date)as día,sum(quantity)as quantity
	from stg.order_line_sale os
	group by 1
	order by 1)
select v1.día, v1.quantity,v2.día, v2.quantity
,(v2.quantity-v1.quantity)as diferencia_ventas
,(v2.quantity-v1.quantity)*1.00/v1.quantity*1.00 as porcentaje_crecimiento
from ventas_día v1
inner join ventas_día v2 on v1.día=v2.día-7
-- 6. Crear una vista de inventario con la cantidad de inventario promedio por dia, tienda y producto, que ademas va a contar con los siguientes datos:
/* - Nombre y categorias de producto: `product_name`, `category`, `subcategory`, `subsubcategory`
- Pais y nombre de tienda: `country`, `store_name`
- Costo del inventario por linea (recordar que si la linea dice 4 unidades debe reflejar el costo total de esas 4 unidades): `inventory_cost`
- Inventario promedio: `avg_inventory`
- Una columna llamada `is_last_snapshot` para el inventario de la fecha de la ultima fecha disponible. Esta columna es un campo booleano.
- Ademas vamos a querer calcular una metrica llamada "Average days on hand (DOH)" `days_on_hand` que mide cuantos dias de venta nos alcanza el inventario. Para eso DOH = Unidades en Inventario Promedio / Promedio diario Unidades vendidas ultimos 7 dias.
- El nombre de la vista es `stg.vw_inventory`
- Notas:
    - Antes de crear la columna DOH, conviene crear una columna que refleje el Promedio diario Unidades vendidas ultimos 7 dias. `avg_sales_last_7_days`
    - El nivel de agregacion es dia/tienda/sku.
    - El Promedio diario Unidades vendidas ultimos 7 dias tiene que calcularse para cada dia.
*/
 create view stg.vw_inventory as
with inventory_by_day as(
select cast(date_trunc('day',date)as date) as día,store_id,item_id, avg(((initial+final)/2)) as avg_inventory
from stg.inventory
group by 1,2,3
order by 1 asc),
inventory_dollars as (select i.*,pm.name as product_name,pm.category,pm.subcategory,pm.subsubcategory
,sm.country,sm.name as store_name, (i.avg_inventory*c.product_cost_usd) as inventory_cost,
CASE
 WHEN i.día=last_value (i.día) over(partition by i.store_id,i.item_id order by i.día asc rows between unbounded preceding and unbounded following) then TRUE
 ELSE FALSE
 END AS is_last_snapshot
from inventory_by_day i
left join stg.product_master pm on i.item_id=pm.product_code
left join stg.store_master sm on sm.store_id=i.store_id
left join stg.cost c on c.product_code=i.item_id),
inventory_and_avg_sales_last_7_days as (select id.*,osd.quantity,
AVG(osd.quantity) OVER (PARTITION BY id.store_id, id.item_id ORDER BY id.día ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_units_sold_last_7_days
from inventory_dollars id
left join stg.order_line_sale osd on osd.date=id.día and osd.store=id.store_id and osd.product=id.item_id)

select *, (avg_inventory/avg_units_sold_last_7_days) as DOH
from inventory_and_avg_sales_last_7_days        

-- ## Semana 4 - Parte A

-- 1. Calcular la contribucion de las ventas brutas de cada producto al total de la orden utilizando una window function. Mismo objetivo que el ejercicio de la parte A pero con diferente metodologia.
with total_sale_usd as(
select order_number, product,sum(sale_usd)as sale_usd
	
from stg.vw_order_line_sale_usd vwos
group by order_number,product)

select *,
sum(sale_usd) over(partition by order_number)as sale_usd_by_order,
((sale_usd)/(sum(sale_usd) over(partition by order_number)))as contri_usd_sale
from total_sale_usd
-- 2. La regla de pareto nos dice que aproximadamente un 20% de los productos generan un 80% de las ventas. Armar una vista a nivel sku donde se pueda identificar por orden de contribucion, ese 20% aproximado de SKU mas importantes. Nota: En este ejercicios estamos construyendo una tabla que muestra la regla de Pareto. 
-- El nombre de la vista es `stg.vw_pareto`. Las columnas son, `product_code`, `product_name`, `quantity_sold`, `cumulative_contribution_percentage`
create view stg.vw_pareto as 
 WITH order_line_sale_dollars AS (
         SELECT os.order_number,
            os.product,
	 		os.quantity,
	        pm.name as product_name,
            pm.category,
            sm.country,
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
        ),
sale_by_product as(select  product as product_code, product_name, sum(quantity) as quantity_sold,sum(sale_usd)as sale_usd
from order_line_sale_dollars
group by product,product_name)

select product_code,product_name,quantity_sold, (sum(sale_usd) over (order by sale_usd desc))/(sum(sale_usd) over ()) as cumulative_contribution_percentage
from sale_by_product
-- 3. Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento.
WITH order_line_sale_dollars AS (
         SELECT os.order_number,
            os.product,
	        os.store,
	 		os.quantity,
	        pm.name as product_name,
            pm.category,
            sm.country,
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
        ),
ventas_por_tienda_mes_a_mes as (
	select cast(date_trunc('month',date)as date)as mes, store, sum(sale_usd)as sale_usd
	from order_line_sale_dollars
	group by 1, 2
	order by 1)
select v2.store,v2.mes, v1.sale_usd as sale_usd_mes_anterior
,(v2.sale_usd-v1.sale_usd)*1.00/v1.sale_usd*1.00 as porcentaje_crecimiento
from ventas_por_tienda_mes_a_mes v1
inner join ventas_por_tienda_mes_a_mes v2 on v1.mes=v2.mes- interval '1 month' and v1.store=v2.store
-- 4. Crear una vista a partir de la tabla return_movements que este a nivel Orden de venta, item y que contenga las siguientes columnas:
/* - Orden `order_number`
- Sku `item`
- Cantidad unidated retornadas `quantity`
- Fecha: `date` Se considera la fecha de retorno aquella el cual el cliente la ingresa a nuestro deposito/tienda.
- Valor USD retornado (resulta de la cantidad retornada * valor USD del precio unitario bruto con que se hizo la venta) `sale_returned_usd`
- Features de producto `product_name`, `category`, `subcategory`
- `first_location` (primer lugar registrado, de la columna `from_location`, para la orden/producto)
- `last_location` (el ultimo lugar donde se registro, de la columna `to_location` el producto/orden)
- El nombre de la vista es `stg.vw_returns`*/
create view stg.vw_returns as
select rm.order_id as order_number,rm.item,rm.quantity,rm.date,(ols.sale_usd*rm.quantity/ols.quantity)as sale_returned_usd,
pm.name as product_name, pm.category,pm.subcategory, rm.from_location as first_location, rm.to_location as last_location
from stg.return_movements rm
left join stg.vw_order_line_sale_usd ols on rm.order_id=ols.order_number and rm.item=ols.product
left join stg.product_master pm on pm.product_code=rm.item
-- 5. Crear una tabla calendario llamada stg.date con las fechas del 2022 incluyendo el año fiscal y trimestre fiscal (en ingles Quarter). El año fiscal de la empresa comienza el primero Febrero de cada año y dura 12 meses. Realizar la tabla para 2022 y 2023. La tabla debe contener:
/* - Fecha (date) `date`
- Mes (date) `month`
- Año (date) `year`
- Dia de la semana (text, ejemplo: "Monday") `weekday`
- `is_weekend` (boolean, indicando si es Sabado o Domingo)
- Mes (text, ejemplo: June) `month_label`
- Año fiscal (date) `fiscal_year`
- Año fiscal (text, ejemplo: "FY2022") `fiscal_year_label`
- Trimestre fiscal (text, ejemplo: Q1) `fiscal_quarter_label`
- Fecha del año anterior (date, ejemplo: 2021-01-01 para la fecha 2022-01-01) `date_ly`
- Nota: En general una tabla date es creada para muchos años mas (minimo 10), en este caso vamos a realizarla para el 2022 y 2023 nada mas.. 
*/
SELECT 
  TO_CHAR(date, 'yyyymmdd')::integer AS date_id,
  CAST(date AS date) AS date,
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
      FROM generate_series(0, 730) n) dd;
-- ## Semana 4 - Parte B

-- 1. Calcular el crecimiento de ventas por tienda mes a mes, con el valor nominal y el valor % de crecimiento. Utilizar self join.
WITH order_line_sale_dollars AS (
         SELECT os.order_number,
            os.product,
	        os.store,
	 		os.quantity,
	        pm.name as product_name,
            pm.category,
            sm.country,
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
        ),
ventas_por_tienda_mes_a_mes as (
	select cast(date_trunc('month',date)as date)as mes, store, sum(sale_usd)as sale_usd
	from order_line_sale_dollars
	group by 1, 2
	order by 1)
select v2.store,v2.mes, v1.sale_usd as sale_usd_mes_anterior
,(v2.sale_usd-v1.sale_usd)*1.00/v1.sale_usd*1.00 as porcentaje_crecimiento
from ventas_por_tienda_mes_a_mes v1
inner join ventas_por_tienda_mes_a_mes v2 on v1.mes=v2.mes- interval '1 month' and v1.store=v2.store
-- 2. Hacer un update a la tabla de stg.product_master agregando una columna llamada brand, con la marca de cada producto con la primer letra en mayuscula. Sabemos que las marcas que tenemos son: Levi's, Tommy Hilfiger, Samsung, Phillips, Acer, JBL y Motorola. En caso de no encontrarse en la lista usar Unknown.
UPDATE stg.product_master
SET brand=
  CASE
  WHEN name like '%Levi%' THEN 'Levi''s'
  WHEN name like '%Tommy Hilfiger%' THEN 'Tommy Hilfigers'
  WHEN name like '%Samsung%' OR name like '%SAMSUNG%'THEN 'Samsung'
  WHEN name like '%Philips%' OR name like '%PHILIPS%' THEN 'Phillips'
  WHEN name like '%Acer%' THEN 'Acer'
  WHEN name like '%JBL%' THEN 'JBL'
  WHEN name like '%Motorola%' OR name like '%MOTOROLA%' THEN 'Motorola'
  else 'Unknown'
  END
-- 3. Un jefe de area tiene una tabla que contiene datos sobre las principales empresas de distintas industrias en rubros que pueden ser competencia y nos manda por mail la siguiente informacion: (ver informacion en md file)
