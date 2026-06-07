create database Heathcare_data;
show databases;

# LETS CREATE NEW TABLE TO WORK WITH WITHOUT TOUCING THE RAW DATA TABLE 
create table healthcare_dataset_staging1 like healthcare_dataset ;
Select * from healthcare_dataset_staging1;

insert healthcare_dataset_staging1
Select * from healthcare_dataset;

# REMOVING DUBLICATES 
# GIVING ROW NUMBER TO FIND OUT IF THERES ANY DOUBLE OR MORE ROW WITH SAME INFORMATION

with cte as (Select *, row_number() over( partition by `Name`, age,  gender, `blood Type`, `medical condition`, `Date of Admission`, Doctor, hospital, `Insurance Provider`, `Billing amount`, `Room number`, `Admission Type`,
`Discharge Date`, medication, `test Results`) as Row_num from healthcare_dataset_staging1) 
Select * from cte where row_num >1;

# CREATING NEW TABLE TO DELETE ALL THE DUBLICATES ROW WITH ROW_NUM>1
CREATE TABLE `healthcare_dataset_staging2` (
  `Name` text,
  `Age` int DEFAULT NULL,
  `Gender` text,
  `Blood Type` text,
  `Medical Condition` text,
  `Date of Admission` text,
  `Doctor` text,
  `Hospital` text,
  `Insurance Provider` text,
  `Billing Amount` double DEFAULT NULL,
  `Room Number` int DEFAULT NULL,
  `Admission Type` text,
  `Discharge Date` text,
  `Medication` text,
  `Test Results` text,
  `Row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


insert into healthcare_dataset_staging2
Select *, row_number() over( partition by `Name`, age,  gender, `blood Type`, `medical condition`, `Date of Admission`, Doctor, hospital, `Insurance Provider`, `Billing amount`, `Room number`, `Admission Type`,
`Discharge Date`, medication, `test Results`) as Row_num from healthcare_dataset_staging1;

Select * from healthcare_dataset_staging2;

Delete from  healthcare_dataset_staging2 where row_num>1;



# CONVERTED DATE COLUMNS FROM TEXT TO DATE 

DESCRIBE healthcare_dataset_staging2;

Update healthcare_dataset_staging2
Set `DATE OF ADMISSION` = str_to_date(`DATE OF ADMISSION`,'%Y-%m-%d') ;

ALTER TABLE healthcare_dataset_staging2
MODIFY COLUMN `DATE OF ADMISSION` DATE;

UPDATE healthcare_dataset_staging2
SET `DISCHARGE DATE` = str_to_date(`DISCHARGE DATE`, '%Y-%m-%d');
 
ALTER TABLE healthcare_dataset_staging2
MODIFY COLUMN `Discharge Date` DATE;



# ROUND THE BILLING AMOUNT TO 2 DECIMAL 

Update healthcare_dataset_staging2
Set `Billing Amount` = Round(`Billing Amount`, 2);




# TRIMMING HOSPITAL NAME TO THROW UNNECESSARY GAS AND SYNTAX 

-- Select Hospital,Trim('and' from Hospital) from   healthcare_dataset_staging2 


Update healthcare_dataset_staging2
set Hospital = Trim( TRAILING ',' from tRIM(hospital));

-- Select * from healthcare_dataset_staging2 where `Date of Admission` > `Discharge Date`;

# ARRANGING NAME COLUMN WITH UPPERCASE FIRST LETTERS IN FIRSTNAME AND LASTNAME 
-- SELECT CONCAT(
--     UPPER(LEFT(SUBSTRING_INDEX(`Name`, ' ', 1), 1)),
--     LOWER(SUBSTRING(SUBSTRING_INDEX(`Name`, ' ', 1), 2)),
--     ' ',
--     UPPER(LEFT(SUBSTRING_INDEX(`Name`, ' ', -1), 1)),
--     LOWER(SUBSTRING(SUBSTRING_INDEX(`Name`, ' ', -1), 2))
-- ) AS Proper_Name
-- FROM  healthcare_dataset_staging2;

Update healthcare_dataset_staging2 
Set `Name` = CONCAT(
    UPPER(LEFT(SUBSTRING_INDEX(`Name`, ' ', 1), 1)),
    LOWER(SUBSTRING(SUBSTRING_INDEX(`Name`, ' ', 1), 2)),
    ' ',
    UPPER(LEFT(SUBSTRING_INDEX(`Name`, ' ', -1), 1)),
    LOWER(SUBSTRING(SUBSTRING_INDEX(`Name`, ' ', -1), 2))
);

# CHECKING IF THERES ANY NULL OR '' BLACK VALUES IN THE DATASET
Select * from healthcare_dataset_staging2
where `name` is Null or `Name` = ''
OR GENDER IS NULL OR GENDER = ''
OR `BLOOD TYPE` IS NULL OR `BLOOD TYPE` = ''
OR `DATE OF ADMISSION` IS NULL OR `DATE OF ADMISSION` = ''
OR DOCTOR IS NULL OR DOCTOR = ''
OR HOSPITAL	IS NULL OR HOSPITAL = ''
OR `INSURANCE PROVIDER`  IS NULL OR `INSURANCE PROVIDER` = ''
;

# DROPPING UNNECESSARY COLUMN FOR INSTANCE (Row_num we added earlier )

Alter table healthcare_dataset_staging2
drop column row_num;




