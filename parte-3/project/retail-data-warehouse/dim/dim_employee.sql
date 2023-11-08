-- Table: dim.employee
DROP TABLE IF EXISTS dim.employee;

CREATE TABLE IF NOT EXISTS dim.employee
(   id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	surname VARCHAR(255) NOT NULL,
	start_date DATE NOT NULL, 
	end_date DATE,
	phone VARCHAR(20),
	country VARCHAR(100),
	province VARCHAR(100),
	store_id INT NOT NULL,
	position VARCHAR(100) NOT NULL,
    is_active boolean,
    
    constraint fk_store_id_employee
    foreign key (store_id)
    references dim.store_master(store_id)

);
