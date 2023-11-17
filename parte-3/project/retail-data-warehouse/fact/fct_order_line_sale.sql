-- Table: fct.order_line_sale
DROP TABLE IF EXISTS fct.order_line_sale;

CREATE TABLE fct.order_line_sale
                 (
                              order_number      VARCHAR(255)
                            , product   VARCHAR(10)
                            , store     SMALLINT
                            , date      date
                            , quantity   int
                            , sale      decimal(18,5)
                            , promotion  decimal(18,5)
                            , tax  decimal(18,5)
                            , credit   decimal(18,5)
                            , currency     varchar(3)
                            , pos        SMALLINT
                            , is_walkout BOOLEAN
                 ,CONSTRAINT pk_order_line_sale 
                 PRIMARY KEY (order_number, product)
                ,constraint fk_product_order_line_sale
                foreign key (product)
                references dim.product_master(product_code)
                ,constraint fk_store_order_line_sale
                foreign key (store)
                references dim.store_master(store_id)
                ,constraint fk_date_order_line_sale
                foreign key (date)
                references dim.date(date)
                 );
