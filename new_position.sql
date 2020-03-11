#Author: Zhaoning Zhang

#This project helps construct table to store company's portfolio information and 
#write queries to select the position difference between forward and later day.

CREATE DATABASE new_position_pick;

USE new_position_pick;

CREATE TABLE position_raw
(
Consolidation VARCHAR(50) NULL,
Account_Number VARCHAR(50) NOT NULL,
Security_ID VARCHAR(50) NULL,
Internal_Sec_ID VARCHAR(50) NULL,
Holding_Type VARCHAR(50) NULL,
File_Type VARCHAR(50) NULL,
Shares INT NULL,
Sec_Category_Code VARCHAR(50) NULL,
As_of_Date DATE NULL,
Accrual_Local VARCHAR(50) NULL,
MV_Local VARCHAR(50) NULL,
Cost_Local VARCHAR(50) NULL,
MV_Base VARCHAR(50) NULL,
Tax_Cost_Base VARCHAR(50) NULL,
Accrual_Base VARCHAR(50) NULL,
Price INT NULL,
Internal VARCHAR(100) NULL,
Asset_Description VARCHAR(100) NULL,
Base_Currency VARCHAR(50) NULL,
Pricing_Currency VARCHAR(50) NULL,
SP_Rating VARCHAR(50) NULL,
Moody_Rating VARCHAR(50) NULL,
Maturity_Date VARCHAR(50) NULL,
Income_Rate DOUBLE NULL,
Ticker_1 VARCHAR(50) NULL,
Ticker_2 VARCHAR(50) NULL,
Ticker_3 VARCHAR(50) NULL,
Sec_Type VARCHAR(50) NULL,
Sector_Code VARCHAR(50) NULL,
Sector_Name VARCHAR(50) NULL,
Industry_Code VARCHAR(50) NULL,
Industry_Name VARCHAR(50) NULL,
Asset_Super_Catg_Code VARCHAR(50) NULL,
Asset_Super_Catg_Name VARCHAR(50) NULL,
Asset_Sub_Catg_Code VARCHAR(50) NULL,
Asset_Sub_Catg_Name VARCHAR(50) NULL,
tbd VARCHAR(50) NULL,
Issue_Type VARCHAR(50) NULL,
Country VARCHAR(50) NULL,
Exchange_Rate DOUBLE NULL,
tbd1 VARCHAR(50) NULL,
Orig_Face INT NULL,
Audit VARCHAR(50) NULL,
combine VARCHAR(100) NULL
);

CREATE TABLE positions AS
(
SELECT Account_Number, Security_ID, As_of_Date, DATE_SUB(As_of_Date, INTERVAL 1 DAY) AS previous_date
FROM position_raw
);

CREATE INDEX positions_index ON positions(Account_Number, As_of_Date, previous_date);

CREATE TABLE pick AS
(
SELECT B.Account_Number, 
       A.Security_ID AS previous_security, 
       B.`Security_ID` AS today_security,
       B.previous_date,
       B.`As_of_Date` AS today_date
FROM positions A
RIGHT JOIN positions B
ON A.`Account_Number`=B.`Account_Number` AND B.previous_date=A.`As_of_Date` AND A.Security_ID=B.Security_ID
);

CREATE TABLE new_position AS
(
SELECT Account_Number, today_security, today_date
FROM pick
WHERE previous_security IS NULL AND previous_date='2018-1-10'
);
