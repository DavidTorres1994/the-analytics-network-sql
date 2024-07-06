/* Crea tabla store_master
Tabla maestra de tiendas 
*/
DROP TABLE IF EXISTS dim.store_master;
      
CREATE TABLE if not exists dim.store_master
                 (
                              store_id  SMALLINT primary key
                            , country           VARCHAR(100)
                            , province      VARCHAR(100)
                            , city         VARCHAR(100)
                            , address      VARCHAR(255)
                            , name         VARCHAR(255)
                            , type           VARCHAR(100)
                            , start_date DATE
                 );
