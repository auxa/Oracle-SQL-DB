DROP TABLE load;
DROP TABLE trailer;
DROP TABLE farmer;
DROP TABLE employee_roles;
DROP TABLE employee;
DROP TABLE roles;
DROP TABLE machine_use;
DROP TABLE machine;
DROP TABLE branch;
DROP TABLE usesOfMachines;
DROP SEQUENCE machineUse_seq;
DROP SEQUENCE load_seq;
DROP SEQUENCE branch_seq; 
DROP SEQUENCE  farmer_seq;
DROP SEQUENCE  trailer_seq;
DROP SEQUENCE  employee_seq;
DROP SEQUENCE  machine_seq;
DROP SEQUENCE roles_seq;


CREATE TABLE branch(
	branch_id int NOT NULL,
	name varchar(255) NOT NULL,
	streetName varchar(255) NOT NULL,
	town varchar(255) NOT NULL,
	county varchar(255) NOT NULL,
	storageCapacity int NOT NULL,
);
ALTER TABLE branch ADD ( CONSTRAINT branch_pk PRIMARY KEY(branch_id));	
CREATE SEQUENCE branch_seq 
	MINVALUE 1
	START WITH 1;

CREATE OR REPLACE TRIGGER branch_trig
BEFORE INSERT ON branch
FOR EACH ROW
BEGIN 
	SELECT branch_seq.NEXTVAL
	INTO :new.branch_id
	FROM dual;
END;
/

CREATE TABLE farmer (
	farmer_id int NOT NULL,
	name varchar(255), 
	streetName varchar(255) NOT NULL,
	phoneNumber int NOT NULL,
	town varchar(255) NOT NULL,
	county varchar(255) NOT NULL	
);
ALTER TABLE farmer ADD ( CONSTRAINT farmer_pk PRIMARY KEY (farmer_id));
CREATE SEQUENCE farmer_seq 
	START WITH 1;
CREATE OR REPLACE TRIGGER farmer_trig
BEFORE INSERT ON farmer
FOR EACH ROW
BEGIN
	SELECT farmer_seq.NEXTVAL
	INTO :new.farmer_id
	FROM dual;
END;
/


CREATE TABLE trailer (
	trailer_id int NOT NULL,
	colour varchar(255) NOT NULL,
	make varchar(255) NOT NULL,
	farmer_id int NOT NULL
);
ALTER TABLE trailer ADD ( CONSTRAINT trailer_pk PRIMARY KEY (trailer_id));
ALTER TABLE trailer ADD ( CONSTRAINT ownership_fk0 FOREIGN KEY (farmer_id) REFERENCES farmer (farmer_id));


CREATE SEQUENCE trailer_seq
	START WITH 1;
CREATE OR REPLACE TRIGGER trailer_inc
BEFORE INSERT ON trailer
FOR EACH ROW
BEGIN 
	SELECT trailer_seq.NEXTVAL
	INTO :new.trailer_id
	FROM dual;
END;
/


CREATE TABLE employee (
	employee_id int NOT NULL,
	name varchar(255) NOT NULL,
	streetName varchar(255) NOT NULL,
	town varchar(255) NOT NULL,
	county varchar(255) NOT NULL,
	salary int NOT NULL,
	phoneNumber int NOT NULL,
	ppsNum int NOT NULL,
	branch_id int NOT NULL
);
ALTER TABLE employee ADD ( CONSTRAINT employee_pk1 PRIMARY KEY(employee_id));
ALTER TABLE employee ADD ( CONSTRAINT emp_branch FOREIGN KEY (branch_id) REFERENCES branch(branch_id));
ALTER TABLE employee ADD ( CONSTRAINT psp_check_min CHECK (ppsNum > 99999999));
ALTER TABLE employee ADD ( CONSTRAINT psp_check_max CHECK (ppsNum < 1000000000));
	
CREATE SEQUENCE employee_seq START WITH 1;

CREATE OR REPLACE TRIGGER employee_id_auto_increment
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN 
	SELECT employee_seq.NEXTVAL
	INTO :new.employee_id
	FROM dual;
END;
/


CREATE TABLE roles(
	roles_id int NOT NULL,
	role varchar(255) NOT NULL
);
ALTER TABLE roles ADD ( CONSTRAINT roles_pk PRIMARY KEY (roles_id));

CREATE SEQUENCE roles_seq START WITH 1;

CREATE OR REPLACE TRIGGER roles_seq
BEFORE INSERT ON roles
FOR EACH ROW
BEGIN 
	SELECT roles_seq.NEXTVAL
	INTO :new.roles_id
	FROM dual;
END;
/

CREATE TABLE employee_roles(
	employee_id int NOT NULL,
	roles_id int NOT NULL
);
ALTER TABLE employee_roles ADD ( CONSTRAINT employee_roles_fk2 FOREIGN KEY(employee_id) REFERENCES employee(employee_id));
ALTER TABLE employee_roles ADD ( CONSTRAINT employee_roles_fk1 FOREIGN KEY(roles_id) REFERENCES roles(roles_id));

CREATE OR REPLACE TRIGGER delete_roles
BEFORE DELETE ON roles
FOR EACH ROW 
WHEN(OLD.roles_id IS NOT NULL)

DECLARE
	var_id varchar(10);
BEGIN
	var_id :=:OLD.roles_id;

	DELETE FROM employee_roles
	WHERE roles_id= var_id;
END delete_roles;
/

CREATE TABLE load (
	load_id int NOT NULL,
	type varchar(255) NOT NULL,
	weight int NOT NULL,
	dateUnloaded DATE NOT NULL,
	employee_id int NOT NULL,
	trailer_id int NOT NULL
);
ALTER TABLE load ADD ( CONSTRAINT load_fk_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id));
ALTER TABLE load ADD ( CONSTRAINT load_fk_trailer  FOREIGN KEY (trailer_id) REFERENCES trailer(trailer_id));
ALTER TABLE load ADD ( CONSTRAINT load_pk PRIMARY KEY (load_id));
ALTER TABLE load ADD ( CONSTRAINT load_type_check CHECK(type IN ('Wheat', 'Barley', 'Rye', 'Oats', 'Corn'));

CREATE SEQUENCE load_seq 
	START WITH 1;

CREATE OR REPLACE TRIGGER load_trig
BEFORE INSERT ON load 
FOR EACH ROW
BEGIN 
	SELECT load_seq.NEXTVAL
	INTO :new.load_id
	FROM dual;
END;
/

CREATE TABLE machine(
	machine_id int NOT NULL,
	make varchar(255) NOT NULL,
	model varchar(255) NOT NULL,
	year int,
	county varchar(2),
	reg_number int
);
ALTER TABLE machine ADD ( CONSTRAINT machine_pk PRIMARY KEY (machine_id));

CREATE SEQUENCE machine_seq START WITH 1;

CREATE OR REPLACE TRIGGER machine_inc
BEFORE INSERT ON machine
FOR EACH ROW
BEGIN 
	SELECT machine_seq.NEXTVAL
	INTO :new.machine_id
	FROM dual;
END;
/

CREATE OR REPLACE TRIGGER delete_farmer
BEFORE DELETE ON farmer
FOR EACH ROW
WHEN(OLD.farmer_id IS NOT NULL)
DECLARE 
	temp_id INTEGER;
BEGIN 
	temp_id :=: OLD.farmer_id;
	DELETE FROM trailer AND load
	WHERE farmer_id=temp_id;
END delete_farmer;
/

CREATE TABLE usesOfMachines(
	use_id int NOT NULL,
	use varchar(255) NOT NULL
);
ALTER TABLE usesOfMachines ADD ( CONSTRAINT machineUSE_pk PRIMARY KEY (use_id));

CREATE SEQUENCE machineUse_seq START WITH 1;

CREATE OR REPLACE TRIGGER machineuse_inc
BEFORE INSERT ON usesOfMachines
FOR EACH ROW
BEGIN 
	SELECT machineUse_seq.NEXTVAL
	INTO :new.use_id
	FROM dual;
END;
/

CREATE TABLE machine_use(
	use_id int NOT NULL,
	machine_id int NOT NULL
);
ALTER TABLE machine_use ADD ( CONSTRAINT machine_use_fk FOREIGN KEY (machine_id) REFERENCES machine(machine_id));
ALTER TABLE machine_use ADD ( CONSTRAINT machine_use_fk2 FOREIGN KEY (use_id) REFERENCES usesOfMachines(use_id));
ALTER TABLE machine_use ADD ( CONSTRAINT machine_use_pk PRIMARY KEY (use_id, machine_id));

INSERT INTO usesOfMachines (use) VALUES ('Load');
INSERT INTO usesOfMachines (use) VALUES ('Unload');
INSERT INTO usesOfMachines (use) VALUES ('Clean');
INSERT INTO usesOfMachines (use) VALUES ('Sweep');
INSERT INTO usesOfMachines (use) VALUES ('Weigh');

INSERT INTO branch (name, streetName, town, county, storageCapacity)
	VALUES ('Glanbia Monasterevin', 'Mill Street', 'Monasterevin', 'Kildare', 10000);
INSERT INTO branch (name, streetName, town, county, storageCapacity)
	VALUES ('Glanbia Athy', 'Barrow Street', 'Athy', 'Kildare', 10000);

INSERT INTO farmer (name, streetName, town, county)
	VALUES ('John Was', 'Bob Street', 'Timahoe', 'Kildare' );
INSERT INTO farmer (name, streetName, town, county)
	VALUES ('Declan Smalling', 'Red Street', 'Baraclose', 'Laois' );
INSERT INTO farmer (name, streetName, town, county)
	VALUES ('David Kelly', 'Grange', 'Athy', 'Kildare' );
INSERT INTO farmer (name, streetName, town, county)
	VALUES ('Joey Fitzpatrick', 'King Road', 'Athy', 'Kildare' );
INSERT INTO farmer (name, streetName, town, county)
	VALUES ('John Froome', 'Sky Road', 'Athy', 'Kildare' );

INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Red', 'RossMore', 3);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Blue', 'RossMore', 2);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Red', 'Eureka', 4);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Black', 'Kingston', 1);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Green', 'IforWilliams', 3);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Silver', 'Blackstome', 2);
INSERT INTO trailer (colour, make, farmer_id) 
	VALUES ('Black', 'Blackstome', 5);


INSERT INTO employee (name, streetName, town,county,salary, phoneNumber, branch_id)
	VALUES ('John Byrne', '13 Seafield Road West', 'Clontarf', 'Dublin 3', 27300, 0851231245, 1);
INSERT INTO employee (name, streetName, town,county,salary, phoneNumber, branch_id)
	VALUES ('James King', 'Red Street', 'Naas', 'Kildare', 39000, 08546622, 1);
INSERT INTO employee (name, streetName, town,county,salary, phoneNumber, branch_id)
	VALUES ('Bobby Pyrne', 'Tight Bend Street', 'Kildangan', 'Kildare', 52000, 089531245, 2);
INSERT INTO employee (name, streetName, town,county,salary, phoneNumber, branch_id)
	VALUES ('Simon Blanch', 'Tall Door Lane', 'Newbridge', 'Kildare', 62000, 08512345678, 2);
INSERT INTO employee (name, streetName, town,county,salary, phoneNumber, branch_id)
	VALUES ('John Croc', 'Silver Hedge Row', 'Kildangan', 'Kildare', 71000, 0851144785, 1);


INSERT INTO load (type, weight, dateUnloaded, employee_id, trailer_id)
	VALUES ('Wheat', 12000, (TO_DATE('2016/05/03', 'yyyy/mm/dd')), 1, 3);
INSERT INTO load (type, weight, dateUnloaded, employee_id, trailer_id)
	VALUES ('Rye', 16000, (TO_DATE('2016/05/03', 'yyyy/mm/dd')), 2, 4);
INSERT INTO load (type, weight, dateUnloaded, employee_id, trailer_id)
	VALUES ('Barley', 10000, (TO_DATE('2016/05/03', 'yyyy/mm/dd')), 3, 4);
INSERT INTO load (type, weight, dateUnloaded, employee_id, trailer_id)
	VALUES ('Rye', 7000, (TO_DATE('2016/05/03', 'yyyy/mm/dd')), 4, 1);
INSERT INTO load (type, weight, dateUnloaded, employee_id, trailer_id)
	VALUES ('Rye', 8000, (TO_DATE('2016/04/03', 'yyyy/mm/dd')), 3, 1);

INSERT INTO machine (make, model, year, county, reg_number)
	VALUES ('Case IH', 'LM105', 161, 'KE', 4528);
INSERT INTO machine (make, model, year, county, reg_number)
	VALUES ('Manitou', 'LS120', 131, 'KE', 251);
INSERT INTO machine (make, model, year, county, reg_number)
	VALUES ('Case IH', 'PUMA 165', 12, 'KE', 196);
INSERT INTO machine (make, model, year, county, reg_number)
	VALUES ('Case IH', 'Farmall', 06, 'KE', 9541);
INSERT INTO machine (make, model, year, county, reg_number)
	VALUES ('McHale', 'SweepMax 200', 161, 'RN', 5220);


INSERT INTO machine_use (use_id, machine_id)
	VALUES (1,3);
INSERT INTO machine_use (use_id, machine_id)
	VALUES (3,1);
INSERT INTO machine_use (use_id, machine_id)
	VALUES (2,4);
INSERT INTO machine_use (use_id, machine_id)
	VALUES (4,2);

INSERT INTO roles(role)
	VALUES ('Manager');
INSERT INTO roles(role)
	VALUES ('Foreman');
INSERT INTO roles(role)
	VALUES ('Driver');
INSERT INTO roles(role)
	VALUES ('Load Attendent');
INSERT INTO roles(role)
	VALUES ('Cleaner');
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (1,1);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (2,1);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (3,3);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (4,2);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (3,3);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (5,4);
INSERT INTO employee_roles(roles_id, employee_id)
	VALUES (1,5);


DECLARE
	salary_temp INTEGER;
	employee_id_temp INTEGER := 3;
BEGIN
	SELECT salary
	INTO salary_temp
	FROM employee
	WHERE employee_id= employee_id_temp;
	dbms_output.put_line(salary_temp);
	dbms_output.put_line('Employee Number: '|| employee_id_temp || ' earned ' || salary_temp);
END;
/