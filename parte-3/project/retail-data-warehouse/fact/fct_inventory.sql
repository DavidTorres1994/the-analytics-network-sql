-- Table fct.inventory
DROP TABLE IF EXISTS fct.inventory;
CREATE TABLE IF NOT EXISTS fct.inventory
   ( date DATE,
     store_id SMALLINT,
     item_id VARCHAR(10),
     initial SMALLINT,
     final SMALLINT,
     constraint fk_store_id_inventory
     foreign key (store_id)
     references dim.store_master(store_id),
     constraint fk_item_id_inventory
     foreign key (item_id)
     references dim.product_master(product_code),
     constraint fk_date_inventory
     foreign key (date)
     references dim.date(date) );
