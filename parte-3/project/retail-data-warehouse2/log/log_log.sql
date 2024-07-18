create or replace procedure etl.log(parameter_table varchar,parameter_date date,parameter_stored_procedure varchar, parameter_username varchar)
language sql
as $$
insert into log.table_updates_2(table_name,date,stored_procedure, username)
select parameter_table,parameter_date,parameter_stored_procedure, parameter_username	
$$
;
