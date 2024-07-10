create or replace procedure etl.sp_dim_product_master()
language plpgsql as $$ 
--declarar variable
DECLARE user_name varchar(10) := current_user;
BEGIN user_name := current_user;
--añadir columna si no existe
alter table dim.product_master
add column if not exists brand VARCHAR(255);
--truncate table dim.product_master;
-- llenar tabla con los datos de stg.product_master
with cte as( select product_code,name,category,subcategory,subsubcategory,material,color,origin,ean
			,is_active,has_bluetooth,size, 
			case
            when lower(name) like '%levi%' then 'Levi''s'
            when lower(name) like '%tommy hilfiger%' then 'Tommy Hilfiger'
			when lower(name) like '%samsung%'  then 'Samsung'
			when lower(name) like '%phillips%'or name like '%PHILIPS%' then 'Phillips'
			when lower(name) like '%acer%' then 'Acer'
			when lower(name) like '%jbl%' then 'JBL'
			when lower(name) like '%motorola%' then 'Motorola'
			else  'Unknown' 
			End as brand
			from stg.product_master)
	insert into dim.product_master(product_code,name,category,subcategory,subsubcategory,material,color,origin,ean
			,is_active,has_bluetooth,size,brand)	
     select * 
	 from cte
	 on conflict(product_code) do update
	 set product_code=excluded.product_code,
	     name=excluded.name,
		 category=excluded.category,
		 subcategory=excluded.subcategory,
		 subsubcategory=excluded.subsubcategory,
		 material=excluded.material,
		 color=excluded.color,
		 origin=excluded.origin,
		 ean=excluded.ean,
		 is_active=excluded.is_active,
		 has_bluetooth=excluded.has_bluetooth,
		 size=excluded.size,
		 brand=excluded.brand;
	--Actualizar la columna 'material'
	  update dim.product_master
	  set material=
	      case
		   when material is NULL then 'Unknown'
		   else initcap(material)
	      end;
	--Actualizar la columna 'color'
	  update dim.product_master
	  set color=
	      case
		   when color is NULL then 'Unknown'
		   else initcap(color)
	      end;
	--sp de logg
    call etl.log('dim.product_master', current_date, 'etl.sp_dim_product_master',user_name);
    END;
$$;
	 
call etl.sp_dim_product_master()
