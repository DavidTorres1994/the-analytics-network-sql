-- Table: fct.return_movements.

DROP TABLE IF EXISTS fct.return_movements
CREATE TABLE IF NOT EXISTS fct.return_movements
(order_id varchar(255),
    return_id varchar(255),
    item varchar(10),
    quantity integer,
    movement_id integer,
    from_location varchar(255),
    to_location varchar(255),
    received_by varchar(255),
    date date,
  constraint fk_item_return_movements
  foreign key (item)
  references dim.product_master(product_code)
  constraint fk_date_return_movements
  foreign key (date)
  references dim.date(date)
);
