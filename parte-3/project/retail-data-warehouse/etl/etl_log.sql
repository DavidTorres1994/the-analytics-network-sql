create or replace procedure  etl.log(parameter_table varchar(255), parameter_date date, parameter_stored_procedure varchar(255),  parameter_username varchar(255))
language sql as $$
insert into log.table_updates(table_name,date,stored_procedure,username)
select parameter_table, parameter_date, parameter_stored_procedure, parameter_username
$$
;
