CREATE OR REPLACE PROCEDURE etl.sp_backup_dim_fct()
LANGUAGE sql AS $$    
--backup tabla fct_order_line_sale    
CREATE TABLE IF NOT EXISTS bkp.bkp_fct_order_line_sale_20240711 AS
SELECT *
FROM fct.order_line_sale;
--backup tabla fct_fx_rate    
CREATE TABLE IF NOT EXISTS bkp.bkp_fct_fx_rate_20240711 AS
SELECT *
FROM fct.fx_rate;   
--backup tabla fct_inventory    
CREATE TABLE IF NOT EXISTS bkp.bkp_fct_inventory_20240711 AS
SELECT *
FROM fct.inventory; 
--backup tabla fct_return_movements    
CREATE TABLE IF NOT EXISTS bkp.bkp_fct_return_movements_20240711 AS
SELECT *
FROM fct.return_movements; 
--backup tabla fct_store_traffic    
CREATE TABLE IF NOT EXISTS bkp.bkp_fct_store_traffic_20240711 AS
SELECT *
FROM fct.store_traffic;   
--backup tabla dim_cost    
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_cost_20240711 AS
SELECT *
FROM dim.cost; 
--backup tabla dim_date    
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_date_20240711 AS
SELECT *
FROM dim.date; 
--backup tabla dim_employee    
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_employee_20240711 AS
SELECT *
FROM dim.employee; 
--backup tabla dim_product_master   
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_product_master_20240711 AS
SELECT *
FROM dim.product_master;
--backup tabla dim_store_master   
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_store_master_20240711 AS
SELECT *
FROM dim.store_master; 
--backup tabla dim_supplier   
CREATE TABLE IF NOT EXISTS bkp.bkp_dim_supplier_20240711 AS
SELECT *
FROM dim.supplier;
  
  $$;

call etl.sp_backup_dim_fct()
