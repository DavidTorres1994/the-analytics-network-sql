-- Table: dim.supplier

DROP TABLE IF EXISTS dim.supplier;
CREATE TABLE IF NOT EXISTS dim.supplier
(  
    product_id VARCHAR(10) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    is_primary boolean,
    constraint fk_product_id_supplier
    foreign key (product_id)
    references dim.product_master(product_code)
);
