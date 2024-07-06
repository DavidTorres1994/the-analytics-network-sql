-- Table: stg.date

-- DROP TABLE IF EXISTS stg.date;

CREATE TABLE IF NOT EXISTS stg.date
(
    date date primary key,
    month date,
    year date,
    dia_de_la_semana text COLLATE pg_catalog."default",
    is_weekend boolean,
    month_label text COLLATE pg_catalog."default",
    fiscal_year date,
    fiscal_year_label text COLLATE pg_catalog."default",
    fiscal_quarter_label text COLLATE pg_catalog."default",
    date_ly date
);
