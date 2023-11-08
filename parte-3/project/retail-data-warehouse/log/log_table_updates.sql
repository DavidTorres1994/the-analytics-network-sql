-- Table: log.table_updates
DROP TABLE IF EXISTS log.table_updates;
CREATE TABLE IF NOT EXISTS log.table_updates
 (  table_name varchar(255),
    date date,
    stored_procedure varchar(255),
    username varchar(255) )
