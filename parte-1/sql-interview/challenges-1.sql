/*
Desafio Entrevista Tecnica Parte 1 
*/


create schema test;

drop table if exists test.test_table_1;
create table test.test_table_1 (id int);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (1);
insert into test.test_table_1 values (2);
insert into test.test_table_1 values (null);
insert into test.test_table_1 values (3);
insert into test.test_table_1 values (3);


drop table if exists test.test_table_2;
create table test.test_table_2 (id int);
insert into test.test_table_2 values (1);
insert into test.test_table_2 values (1);
insert into test.test_table_2 values (null);
insert into test.test_table_2 values (4);
insert into test.test_table_2 values (4);


select * from test.test_table_1;
select * from test.test_table_2;

--1. Como encuentro duplicados en una tabla. Dar un ejemplo mostrando duplicados de la columna orden en la tabla de ventas. (responder teoricamente)
--Busco en la tabla solo las ordenes, uso un count para contarlas y agrupo y filtro las ordenes que aparecen mas de una vez
select os.order_number
, count(*)
from stg.order_line_sale os
group by os.order_number
having count(*)>1
ORDER BY count(*) desc
--2. Como elimino duplicados? (responder teoricamente)
-- Primero agrego una columna ID para tener una columna con valores únicos
ALTER TABLE stg.order_line_sale
ADD COLUMN id SERIAL PRIMARY KEY
--Uso una consulta que me elimine los duplicados, fijandose que no se elimine la orden que inicialmente se encontró duplicada
DELETE FROM stg.order_line_sale as ols
WHERE EXISTS (
	select 1
    from stg.order_line_sale as sub_ols
	where sub_ols.order_number=ols.order_number
	AND sub_ols.id<>ols.id)


--3. Cual es la diferencia entre UNION y UNION ALL. (responder teoricamente)
--La principal diferencia radica en como cada uno maneja las filas duplicadas. UNION une las tablas y elimina las filas duplicadas para generar 
un conjunto de resultados únicos. --UNION ALL une las tablas y mantiene todas las filas incluido duplicadoss. 
--4. Como encuentro registros en una tabla que no estan en otra tabla. (responder teoricamente y usando la table_1 y table_2 como ejemplo)
--En este caso se usa left join para unir tabla 1 y tabla 2 en donde se mantiene los valores de tabla 1 y se toma los valores comunes de tabla 2,
saber cual serían los registros de tabla 2 no comunes que no estan en tabla 1 se agrega la condición en donde el id de tabla 2 sería nulo
select * 
from test.test_table_1 as t1
left join test.test_table_2 as t2 on t1.id=t2.id
where t2.id is NULL
--5. Cual es la diferencia entre INNER JOIN y LEFT JOIN.  (responder teoricamente y usando la table_1 y table_2 como ejemplo)
La difrenecia entre INNER JOIN Y LEFT JOIN es que INNER JOIN al juntar las tablas da como resultado unicamente los resultados en común de ambas
y LEFT JOIN mantiene todos los registros de la primera tabla que se relaciona, mientras que de la otra solo trae los registros comunes que tiene
con la primera tabla
