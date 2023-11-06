-- Table: dim.employee
DROP TABLE IF EXISTS dim.employee;

CREATE TABLE IF NOT EXISTS dim.employee
(   id SERIAL PRIMARY KEY,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    surname character varying(255) COLLATE pg_catalog."default" NOT NULL,
    start_date date NOT NULL,
    end_date date,
    phone character varying(100) COLLATE pg_catalog."default",
    country character varying(100) COLLATE pg_catalog."default",
    province character varying(100) COLLATE pg_catalog."default",
    store_id SMALLINT NOT NULL,
    "position" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    constraint fk_store_id_employee
    foreign key (store_id)
    references dim.store_master(store_id)

);
