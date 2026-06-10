--Inicialización del set global
SET GLOBAL net_read_timeout = 3600;
SET GLOBAL net_write_timeout = 3600;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;

--Carga de datos 
--creación y carga de tabla de transferss
USE proyectoalm;
CREATE TABLE Transf (
transaction_id INT AUTO_INCREMENT PRIMARY KEY,
time_tran TIMESTAMP, from_bank int, from_account varchar(50), 
to_bank int, to_account VARCHAR(50), amount_received DECIMAL(18,2), receiving_currency VARCHAR(50), 
amount_paid DECIMAL(18,2), payment_currency VARCHAR(50), payment_format varchar(50), is_laundering Int);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/HI-Medium_Trans.csv'
INTO TABLE proyectoalm.transf
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(time_tran, from_bank, from_account, to_bank, to_account, 
amount_received, receiving_currency, amount_paid, 
payment_currency, payment_format, is_laundering);

--Creación de la tabla accounts

ALTER TABLE proyectoalm.accounts
CHANGE COLUMN `Bank Name` bank_name VARCHAR(50),
CHANGE COLUMN `Bank ID` bank_id BIGINT,
CHANGE COLUMN `Account Number` account_number VARCHAR(50),
CHANGE COLUMN `Entity ID` entity_id VARCHAR(50),
CHANGE COLUMN `Entity Name` entity_name VARCHAR(50);
ALTER TABLE proyectoalm.accounts
ADD PRIMARY KEY (bank_id, account_number);

--creación y carga de tabla de Banks
CREATE TABLE proyectoalm.banks AS 
SELECT DISTINCT bank_name, `Bank ID` as bank_id 
FROM proyectoalm.accounts;
--Eliminicación de duplicados
CREATE TABLE proyectoalm.Tabla_Temp AS SELECT DISTINCT * FROM proyectoalm.banks;
TRUNCATE TABLE proyectoalm.banks;
INSERT INTO proyectoalm.banks SELECT DISTINCT bank_name, bank_id FROM proyectoalm.accounts;
DROP TABLE Tabla_Temp;

--Revisión de duplicados en la tabla Banks
SELECT bank_id, COUNT(*)  FROM proyectoalm.banks 
GROUP BY bank_id
HAVING COUNT(*) > 1;


