DROP TABLE IF EXISTS stg.employee;

CREATE TABLE IF NOT EXISTS stg.employee
(
    id integer NOT NULL DEFAULT nextval('employees_id_seq'::regclass),
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    surname character varying(255) COLLATE pg_catalog."default" NOT NULL,
    start_date date NOT NULL,
    end_date date,
    phone character varying(100) COLLATE pg_catalog."default",
    country character varying(100) COLLATE pg_catalog."default",
    province character varying(100) COLLATE pg_catalog."default",
    store_id integer NOT NULL,
    "position" character varying(100) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT employees_pkey PRIMARY KEY (id)
);
