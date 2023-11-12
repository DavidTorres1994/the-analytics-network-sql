-- Table: stg.employee

DROP TABLE IF EXISTS stg.employee;

CREATE TABLE IF NOT EXISTS stg.employee
(
    id SERIAL PRIMARY KEY,
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
	current_flag BOOLEAN,
    effective_start_date DATE,
    effective_end_date DATE
);
