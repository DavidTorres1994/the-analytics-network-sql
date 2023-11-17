-- Table. fct.store_traffic
DROP TABLE IF EXISTS fct.store_traffic;
CREATE TABLE IF NOT EXISTS  fct.store_traffic
                 (
                              store_id SMALLINT
                            , date  date
                            , traffic SMALLINT
	        , constraint pk_store_traffic
	          primary key (store_id,date)
                ,constraint fk_store_id_store_traffic
		            foreign key (store_id)
		            references dim.store_master(store_id)
                ,constraint fk_date_store_traffic
                foreign key (date)
                references dim.date(date)
                 );
