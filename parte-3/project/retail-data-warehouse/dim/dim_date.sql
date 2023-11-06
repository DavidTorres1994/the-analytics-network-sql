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
	date_ly date,
  constraint fk_date_date
  foreign key (date)
  references fct.inventory(date)
  references fct.store_traffic(date)
  references fct.return_movements(date)
  references fct.order_line_sale(date),
  constraint fk_month_date
  foreign key (month)	
  references fct.fx_rate(month)
);
