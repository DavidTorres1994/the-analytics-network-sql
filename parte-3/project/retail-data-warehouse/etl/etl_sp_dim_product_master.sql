CREATE OR REPLACE PROCEDURE etl.sp_dim_product_master()
LANGUAGE plpgsql AS $$    
DECLARE username varchar(10) := current_user;	
BEGIN username := current_user;
    -- Añadir una columna si no existe
    ALTER TABLE dim.product_master
    ADD COLUMN IF NOT EXISTS brand VARCHAR(255);
   
    
    INSERT INTO dim.product_master(product_code,name,category,subcategory,subsubcategory,material,color,origin,ean,is_active,has_bluetooth,size,brand)
    SELECT *
    FROM stg.product_master 
    ON CONFLICT(product_code) DO UPDATE
    SET product_code = excluded.product_code,
        name = EXCLUDED.name,
        category = EXCLUDED.category,
        subcategory = EXCLUDED.subcategory,
        material = EXCLUDED.material,
        color = EXCLUDED.color,
        origin = EXCLUDED.origin,
        ean = EXCLUDED.ean,
        is_active = EXCLUDED.is_active,
        has_bluetooth = EXCLUDED.has_bluetooth,
        size = EXCLUDED.size,
        brand = EXCLUDED.brand;
  
    
    -- Actualizar la columna 'material'
    UPDATE dim.product_master
    SET material = 
        CASE 
            WHEN material IS NULL THEN 'Unknown'
            ELSE initcap(material)
        END;
    
    -- Actualizar la columna 'color'
    UPDATE dim.product_master
    SET color = 
        CASE 
            WHEN color IS NULL THEN 'Unknown'
            ELSE initcap(color)
        END;
--sp de logg
    call etl.log('dim.product_master', current_date, 'etl.sp_dim_product_master',username);
END;
$$;
call etl.sp_dim_product_master()
