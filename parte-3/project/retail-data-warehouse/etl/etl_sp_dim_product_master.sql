CREATE OR REPLACE PROCEDURE etl.sp_dim_product_master()
LANGUAGE plpgsql AS $$    
BEGIN
    INSERT INTO dim.product_master(product_code,name,category,subcategory,subsubcategory,material,color,origin,ean,is_active,has_bluetooth,size)
    VALUES (product_code, name, category, subcategory, subsubcategory, material, color, origin, ean, is_active, has_bluetooth, size)
	ON CONFLICT(product_code) DO UPDATE
    SET name = EXCLUDED.name,
        category = EXCLUDED.category,
        subcategory = EXCLUDED.subcategory,
        material = EXCLUDED.material,
        color = EXCLUDED.color,
        origin = EXCLUDED.origin,
        ean = EXCLUDED.ean,
        is_active = EXCLUDED.is_active,
        has_bluetooth = EXCLUDED.has_bluetooth,
        size = EXCLUDED.size;
    -- Añadir una columna si no existe
    ALTER TABLE dim.product_master
    ADD COLUMN IF NOT EXISTS brand VARCHAR(255);
    
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
END;
$$;


