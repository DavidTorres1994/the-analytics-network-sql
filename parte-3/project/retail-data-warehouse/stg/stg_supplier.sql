-- Table: stg.supplier

DROP TABLE IF EXISTS stg.supplier;

CREATE TABLE IF NOT EXISTS stg.supplier
(
    product_id character varying(255) COLLATE pg_catalog."default",
    name character varying(255) COLLATE pg_catalog."default",
    is_primary boolean
);
