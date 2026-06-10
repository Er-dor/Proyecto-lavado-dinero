
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


--creación y carga de tabla de Accountss
import pandas as pd
-- Python
from sqlalchemy import create_engine

engine = create_engine('mysql+pymysql://root:31518@127.0.0.1/proyectoalm')

df = pd.read_csv("C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/HI-Medium_accounts.csv")
df.to_sql('accounts', con=engine, if_exists='replace', index=False)
--SQL
ALTER TABLE proyectoalm.accounts
CHANGE COLUMN `Bank Name` bank_name VARCHAR(50),
CHANGE COLUMN `Bank ID` bank_id BIGINT,
CHANGE COLUMN `Account Number` account_number VARCHAR(50),
CHANGE COLUMN `Entity ID` entity_id VARCHAR(50),
CHANGE COLUMN `Entity Name` entity_name VARCHAR(50);
ALTER TABLE proyectoalm.accounts
ADD PRIMARY KEY (bank_id, account_number);

--creación y carga de tabla de Accountss
CREATE TABLE proyectoalm.banks AS 
SELECT DISTINCT bank_name, `Bank ID` as bank_id 
FROM proyectoalm.accounts;
--Eliminicación de duplicados
CREATE TABLE proyectoalm.Tabla_Temp AS SELECT DISTINCT * FROM proyectoalm.banks;
TRUNCATE TABLE proyectoalm.banks;
INSERT INTO proyectoalm.banks SELECT * FROM proyectoalm.accounts;
DROP TABLE Tabla_Temp;

--Revisión de duplicados en la tabla Banks
SELECT bank_id, COUNT(*)  FROM proyectoalm.banks 
GROUP BY bank_id
HAVING COUNT(*) > 1;



--¿Qué cuentas tienen mayor cantidad de trransacciones enviadas?
select t.from_account,  count(t.from_account) as total_mov
from proyectoalm.transf t
group by t.from_account
order by total_mov desc

--¿Qué cuentas tienen mayor volumrn de trransacciones enviadas y recibidas?
--La subquery env crea una tabla temporal con todas las cuentas que enviaron dinero y cuántas veces
--La subquery rec crea otra tabla temporal con todas las cuentas que recibieron dinero y cuántas veces
--El LEFT JOIN une esas dos tablas temporales por el número de cuenta
SELECT 
    env.cuenta,
    env.envios,
    rec.recepciones
FROM 
    (SELECT from_account AS cuenta, COUNT(*) AS envios
     FROM proyectoalm.transf
     GROUP BY from_account) AS env
LEFT JOIN 
    (SELECT to_account AS cuenta, COUNT(*) AS recepciones
     FROM proyectoalm.transf
     GROUP BY to_account) AS rec
ON env.cuenta = rec.cuenta
ORDER BY env.envios DESC;


--¿cómo se comportan las cuentas con un gran volumen de  transacciones cuando se filtran por tipo de moneda?  
--Explorar las cuentas que operan en monedas no-dólar ¿las monedas extranjeras o Bitcoin lideran en la cantidad de transacciones?
select from_account, count(*) as ctr
from  proyectoalm.transf as tf
where payment_currency != "US Dollar"
group by tf.from_account
order by ctr desc
-- ¿El uso de dollar como metodo de transacciones es mayoritario respecto a las otras monedad?
select from_account, count(*) as ctr
from  proyectoalm.transf as tf
where payment_currency = "US Dollar"
group by tf.from_account
order by ctr desc

--Los usuarios con mas transacciones ¿cuáles son los bancos con mas apariciones? 
select tf.from_account as Act, tf1.bank_name,  count(*) as aparicion 
from  proyectoalm.transf as tf
left join proyectoalm.banks as tf1 on tf.to_bank = tf1.bank_id 
where tf.from_account = '100428660'
group by tf1.bank_name 
order by aparicion desc

--Visualización de transacciones por hora 
SELECT hour(tg.time_tran)  as hora, count(*) as cuantas 
 FROM proyectoalm.transf as tg
 group by hour(tg.time_tran)
 order by hora ;

--Visualización en hora 12:00 am y 14:00 pm
SELECT HOUR(time_tran) as hora, payment_currency, COUNT(*) as cuantas
FROM proyectoalm.transf
WHERE HOUR(time_tran) = 0 (14)
GROUP BY payment_currency
ORDER BY cuantas DESC;


-- Estadísticas generales de montos
SELECT 
    MIN(amount_paid) as minimo,
    MAX(amount_paid) as maximo,
    AVG(amount_paid) as media
FROM proyectoalm.transf;

-- Mediana
WITH transferencias_orden AS (
    SELECT 
        tf.amount_paid,
        ROW_NUMBER() OVER (ORDER BY tf.amount_paid) AS num_fila,
        COUNT(*) OVER() AS total_filas
    FROM proyectoalm.transf AS tf
)
SELECT AVG(amount_paid) AS mediana
FROM transferencias_orden
WHERE num_fila IN (
    FLOOR((total_filas + 1) / 2), 
    CEIL((total_filas + 1) / 2)
);

-- Distribución por rangos cuenta 100428660
SELECT tf.from_account, 
COUNT(CASE WHEN tf.amount_paid <= 100 THEN 1 END)*100/COUNT(*) AS Prc_100, 
COUNT(CASE WHEN tf.amount_paid > 100 AND tf.amount_paid <= 500 THEN 1 END)*100/COUNT(*) AS Prc_500,
COUNT(CASE WHEN tf.amount_paid > 500 AND tf.amount_paid <= 1000 THEN 1 END)*100/COUNT(*) AS Prc_1000,
COUNT(CASE WHEN tf.amount_paid > 1000 AND tf.amount_paid < 10000 THEN 1 END)*100/COUNT(*) AS Prc_10000
FROM proyectoalm.transf as tf
WHERE tf.from_account = '100428660'
GROUP BY tf.from_account;

-- Porcentaje de transacciones bajo $10,000 por cuenta
SELECT tf.from_account, 
COUNT(CASE WHEN tf.amount_paid < 10000 THEN 1 END)*100/COUNT(*) AS Porcentaje_transf
FROM proyectoalm.transf as tf
WHERE tf.from_account = '100428660'
GROUP BY tf.from_account;

-- Porcentaje general del dataset bajo $10,000
SELECT 
COUNT(CASE WHEN amount_paid < 10000 THEN 1 END)*100/COUNT(*) AS Porcentaje_transf
FROM proyectoalm.transf;


