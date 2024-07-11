DROP TABLE IF EXISTS dim.employee;

CREATE TABLE IF NOT EXISTS dim.employee
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
     current_flag boolean,
    effective_start_date date,
    effective_end_date date,	
    CONSTRAINT employees_pkey PRIMARY KEY (id)
    constraint fk_start_date_employee
		foreign key (start_date)
		references dim.date(date)
    constraint fk_end_date_employee
		foreign key (end_date)
		references dim.date(date)
    constraint fk_store_id_employee
		foreign key (store_id)
		references dim.store_master(store_id)
);
