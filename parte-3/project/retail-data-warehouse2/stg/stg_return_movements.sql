-- Table: stg.return_movements
DROP TABLE IF EXISTS stg.return_movements;

CREATE TABLE IF NOT EXISTS stg.return_movements
(
    order_id varchar(255),
    return_id varchar(255),
    item varchar(255),
    quantity integer,
    movement_id integer,
    from_location varchar(255),
    to_location varchar(255),
    received_by varchar(255),
    date date
);
