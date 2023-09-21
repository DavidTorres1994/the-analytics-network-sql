-- ## Semana 1 - Parte A


-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * from stg.product_master where categoria = 'Electro'
select *
from stg.product_master
where category= 'Electro'
-- 2. Cuales son los producto producidos en China?
select product_code, name 
from stg.product_master
where origin= 'China'
-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select *
from stg.product_master
where category= 'Electro'
order by name
-- 4. Cuales son las TV que se encuentran activas para la venta?
select *
from stg.product_master
where subcategory= 'TV'
and is_active='true'
-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select store_id, name, start_date
from stg.store_master
where country='Argentina'
order by start_date
-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select * from stg.order_line_sale
order by date desc
limit 5
-- 7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select *
from stg.super_store_count
order by date
limit 10
-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select product_code, name
from stg.product_master
where name NOT LIKE '%Soporte TV%'
and name NOT LIKE '%Control Remoto%'
and category='Electro'
-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select * from stg.order_line_sale
where sale>100000
AND currency IN ('ARS','URU')
-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select *
from stg.order_line_sale
where EXTRACT(MONTH FROM date)=10
-- 11. Mostrar todos los productos que tengan EAN.
select *
from stg.product_master
WHERE ean IS NOT Null
-- 12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select *
from stg.order_line_sale
where date BETWEEN '2022-10-01' AND '2022-11-10'
-- ## Semana 1 - Parte B

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select DISTINCT country 
from stg.store_master
-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select subcategory,COUNT(product_code)
from stg.product_master
Where is_active=True
Group by subcategory
-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
Select order_number, sale
from stg.order_line_sale
where sale>100000 and currency='ARS'
-- 4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
Select currency, sum(promotion) as Total_Promotion
from stg.order_line_sale 
where extract(month from date)=11 and extract(year from date)=2022
group by currency
-- 5. Obtener los impuestos pagados en Europa durante el 2022.
Select sum(tax) as Total_Tax
from stg.order_line_sale 
where  extract(year from date)= 2022 and currency='EUR'
-- 6. En cuantas ordenes se utilizaron creditos?
SELECT  COUNT(DISTINCT order_number)
from stg.order_line_sale
where credit is NOT NULL
-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
SELECT store, (SUM(promotion)/SUM(sale))as Porcentaje_de_descuentos_por_tienda
from stg.order_line_sale
group by store
-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
SELECT store_id , SUM((initial+final)/2)/COUNT(DISTINCT date) as Inv_Prom_por_día
FROM stg.inventory
GRoup by store_id
-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina. dudas
SELECT product,SUM((sale-coalesce(promotion,0)+coalesce(tax,0))) as Venta_neta, (SUM(promotion)/SUM(sale))as Porcentaje_de_descuentos_por_producto 
from stg.order_line_sale
where currency = 'ARS'
Group by product 
-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
SELECT sc.store_id, TO_DATE(sc.date,'YYYY-MM-DD')AS date, sc.traffic
FROM stg.super_store_count sc
UNION ALL
SELECT mc.store_id, TO_DATE(CAST(mc.date AS VARCHAR),'YYYYMMDD')AS date, mc.traffic
FROM stg.market_count mc
-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
SELECT * FROM stg.product_master
where nombre like '%PHILIPS%' and is_active=True
-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal de las ventas (sin importar la moneda).
select store, currency , sum(sale) as valor_de_ventas
from stg.order_line_sale
Group by store, currency
order by valor_de_ventas desc
-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
SELECT product, sum(sale)/sum(quantity) as Precio_prom_venta
from stg.order_line_sale
Group by product
-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
SELECT order_number,SUM(coalesce(tax,0))/sum(sale) as Tasa_de_impuestos
from stg.order_line_sale
Group by order_number

-- ## Semana 2 - Parte A

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
SELECT name, product_code, category, CASE  
				     WHEN color IS NULL THEN 'Unknown'
		                     ELSE color
                                     END AS color
FROM stg.product_master
where name like '%PHILIPS%' or name like '%Samsung%'
-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
WITH store_sale as (
select store, SUM(sale) as ventas_brutas, sum(tax) as impuestos, currency
from stg.order_line_sale
group by store, currency)
select  sm.country, sm.province, sum(ss.ventas_brutas)as ventas_brutas_país_provincia, sum(ss.impuestos) as impuestos_país_provincia, ss.currency
from stg.store_master sm
left join store_sale ss on sm.store_id = ss.store
group by sm.country, sm.province, ss.currency

-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
SELECT  subcategory,currency,sum(sale) as ventas_totales
from stg.order_line_sale os
left join stg.product_master pm on pm.product_code=os.product
group by subcategory, currency
order by subcategory, currency

-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
SELECT pm.subcategory, CONCAT(sm.country,'-',sm.province) as país_provincia,sum(os.quantity) as unidades_vendidas
FROM stg.order_line_sale os
left join stg.product_master pm on os.product=pm.product_code
LEFT JOIN stg.store_master sm on sm.store_id=os.store
group by pm.subcategory,país_provincia
order by país_provincia
-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
create view vista_tienda as 
select sm.name, sc.traffic, sc.date 
from stg.super_store_count sc
left join stg.store_master sm on sc.store_id= sm.store_id
-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
SELECT  sm.name,i.item_id, SUM((i.initial+i.final)/2)/COUNT(DISTINCT EXTRACT(month from i.date)) as Inv_Prom_por_mes
FROM stg.inventory i
left join stg.store_master sm on i.store_id=sm.store_id
Group by sm.name,i.item_id
-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select CASE                                 
       WHEN material IS NULL THEN 'Unknown'
	   WHEN material = 'PLASTICO' THEN 'plastico'
	   ELSE material
	   END AS material
	   ,sum(quantity)as Cantidad_unidades_vendidas
from stg.order_line_sale os
left join stg.product_master pm on pm.product_code=os.product
group by 
	   CASE                                 
           WHEN material IS NULL THEN 'Unknown'
	   WHEN material = 'PLASTICO' THEN 'plastico'
	   ELSE material
	END;
-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
SELECT os.order_number, os.sale, os.currency, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date
-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
with ventas_totales_en_dolares as (SELECT os.order_number, os.sale, os.currency, cast(date_trunc('month',os.date) as date) as date,
      CASE
	  WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
	  WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
	  WHEN currency = 'URU' THEN sale/fx_rate_usd_URU
	  ELSE sale
	  END AS Ventas_en_dolares
from stg.order_line_sale os
left join stg.monthly_average_fx_rate mr on mr.month=date)
Select SUM(Ventas_en_dolares) as ventas_totales_de_la_empresa_en_dolares
from ventas_totales_en_dolares
-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
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
SELECT *, (ventas_en_dolares-descuento_en_dolares-costo_linea) as margen_de_venta 
FROM order_line_Sale_dollars
-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select os.order_number, pm.subcategory, count(distinct os.product) as Item_distinto
from stg.order_line_sale os
left join stg.product_master pm on os.product=pm.product_code
group by os.order_number, pm.subcategory

-- ## Semana 2 - Parte B

-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
CREATE SCHEMA IF NOT EXISTS bkp;
CREATE TABLE bkp.bkp_product_master_20230918 AS
SELECT *
FROM stg.product_master
-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
--Actualizar material
UPDATE bkp.bkp_product_master_20230918
SET material = 'N/A'
WHERE material IS NULL
--Actualizar color
UPDATE bkp.bkp_product_master_20230918
SET color = 'N/A'
WHERE color IS NULL 
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp.bkp_product_master_20230918
set is_active=false
where subsubcategory = 'Control remoto' 
-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
UPDATE bkp.bkp_product_master_20230918
SET is_local = CASE
		 WHEN origin = 'Argentina' then true
		 ELSE false
	    END  
-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
ALTER TABLE stg.order_line_sale
ADD COLUMN line_key VARCHAR
UPDATE stg.order_line_sale
SET line_key = order_number||'-'||product
-- 6. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), name, surname, start_date, end_name, phone, country, province, store_id, position. Decidir cual es el tipo de dato mas acorde.
CREATE TABLE employees (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	surname VARCHAR(255) NOT NULL,
	start_date DATE NOT NULL, 
	end_date DATE,
	phone VARCHAR(20),
	country VARCHAR(100),
	province VARCHAR(100),
	store_id INT NOT NULL,
	position VARCHAR(100) NOT NULL
)  
-- 7. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
    -- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
    -- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
    -- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
    -- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.
-- Datos Juan
INSERT INTO employees (name, surname, start_date, phone, country, province, store_id, position)
VALUES('Juan', 'Perez', '2022-01-01','+541113869867', 'Argentina', 'Santa Fe', 2, 'Vendedor')
-- Datos Catalina
INSERT INTO employees (name, surname, start_date, phone, country, province, store_id, position)
VALUES('Catalina', 'Garcia', '2022-03-01','','Argentina', 'Buenos Aires', 2, 'Representante Comercial')
-- Datos Ana
INSERT INTO employees (name, surname, start_date,end_date, country, province, store_id, position)
VALUES('Ana', 'Valdez', '2020-02-21','2022-03-01', 'España', ' Madrid', 8, 'Jefe Logistica')
-- Datos Fernando
INSERT INTO employees (name, surname, start_date, country, province, store_id, position)
VALUES('Fernando', 'Moralez','2022-04-04', 'España', ' Valencia', 9, 'Vendedor')
  
-- 8. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
CREATE TABLE cost_backup AS
SELECT *, NOW() AS last_updated_ts
FROM stg.cost  
-- 9. En caso de hacer un cambio que deba revertirse en la tabla "order_line_sale" y debemos volver la tabla a su estado original, como lo harias?
CREATE SCHEMA IF NOT EXISTS bkp;
CREATE TABLE bkp.bkp_order_line_sale_20230919 AS
SELECT *
FROM stg.order_line_sale

DROP TABLE IF EXISTS stg.order_line_sale

-- Restaura la tabla original desde la tabla de respaldo
CREATE TABLE stg.order_line_sale AS
SELECT *
FROM bkp.bkp_order_line_sale_20230919
