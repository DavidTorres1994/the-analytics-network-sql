CREATE OR REPLACE PROCEDURE etl.sp_dim_date()
LANGUAGE plpgsql AS $$    
BEGIN
   
    UPDATE dim.date
    SET Dia_de_la_semana = initcap(Dia_de_la_semana);  
    -- Actualizar la columna 'month_label'
    UPDATE dim.date
    SET month_label = initcap(month_label);
    UPDATE dim.date
    SET fiscal_year_label = initcap(fiscal_year_label);
    UPDATE dim.date
    SET fiscal_quarter_label = initcap(fiscal_quarter_label);
    INSERT INTO dim.date(date,month,year,Dia_de_la_semana,is_weekend,month_label,fiscal_year,fiscal_year_label,fiscal_quarter_label,date_ly)
    SELECT 

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
        FROM generate_series(0, 1825) n) dd;
END;
$$;
