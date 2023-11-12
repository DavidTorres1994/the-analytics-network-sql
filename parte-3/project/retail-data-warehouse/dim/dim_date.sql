-- Table: dim.date

DROP TABLE IF EXISTS dim.date;

CREATE TABLE IF NOT EXISTS dim.date
(
	date date PRIMARY KEY,
	month date, 
	year date,
	Dia_de_la_semana text,
	is_weekend boolean,
	month_label text,
	fiscal_year date,
	fiscal_year_label text,
	fiscal_quarter_label text,
	date_ly date) 
