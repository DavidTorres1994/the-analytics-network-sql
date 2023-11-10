-- Table: dim.employee
DROP TABLE IF EXISTS dim.employee;

CREATE TABLE IF NOT EXISTS dim.employee
(   id SERIAL PRIMARY KEY,
	employee_key SERIAL UNIQUE,
	name VARCHAR(255) NOT NULL,
	surname VARCHAR(255) NOT NULL,
	start_date DATE NOT NULL, 
	end_date DATE,
	phone VARCHAR(20),
	country VARCHAR(100),
	province VARCHAR(100),
	store_id INT NOT NULL,
	position VARCHAR(100) NOT NULL,
       -- is_active boolean,
	current_flag BOOLEAN,
        effective_start_date DATE,
         effective_end_date DATE,
    
    constraint fk_store_id_employee
    foreign key (store_id)
    references dim.store_master(store_id),
    constraint fk_start_date_employee
    foreign key (start_date)
    references dim.date(date),
     constraint fk_end_date_employee
    foreign key (end_date)
    references dim.date(date)
);

