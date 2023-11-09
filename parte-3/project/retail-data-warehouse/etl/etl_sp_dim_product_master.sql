create or replace procedure etl.sp.dim.product_master()
language sql as $$
BEGIN
  -- Añadir una columna si no existe
  ALTER TABLE dim.prduct_master
  ADD COLUMN IF NOT EXISTS brand VARCHAR(255); 
  -- Actualizar la columna 'material'
  UPDATE dim.prduct_master
  SET material= 
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
$$
;
