-- normalizing table
/* i want to normalize it into 4 tables in order to make it less redundant with new data coming in, reducing the possibility of data anomalies, improving the integrity and facilitating better query performance.
tables due to create by categories are:
1.	Orders:
	ORDERNUMBER as the primary key
	ORDERDATE
	DAYS_SINCE_LAST_ORDER
	STATUS
	CUSTOMERNAME as primary key
2.	Products:
	PRODUCTCODE as primary key
	PRODUCTLINE
	MSRP
3.	Customers:
	CUSTOMERNAME as primary key
	PHONE
	ADDRESSLINE1
	CITY
	POSTALCODE
	COUNTRY
	CONTACTLASTNAME
	CONTACTFIRSTNAME
4.	OrderItems
	ORDERNUMBER as foreign key and primary keys
	ORDERLINENUMBER
	PRODUCTCODE as foreign key
	QUANTITYORDERED
	PRICEEACH
	SALES

*/

-- Create Orders Table
CREATE TABLE Orders (
    ORDERNUMBER VARCHAR(255),
    ORDERDATE DATE,
    DAYS_SINCE_LASTORDER INT,
    STATUS VARCHAR(50),
    CUSTOMERNAME VARCHAR(255),
)

-- Create Products Table
CREATE TABLE Products (
    PRODUCTCODE VARCHAR(255),
    PRODUCTLINE VARCHAR(255),
    MSRP DECIMAL(10, 2)
)

-- Create Customers Table
CREATE TABLE Customers (
    CUSTOMERNAME VARCHAR(255),
    PHONE VARCHAR(20),
    ADDRESSLINE1 VARCHAR(255),
    CITY VARCHAR(255),
    POSTALCODE VARCHAR(20),
    COUNTRY VARCHAR(100),
    CONTACTLASTNAME VARCHAR(255),
    CONTACTFIRSTNAME VARCHAR(255)
)

-- Create Order Items Table
CREATE TABLE OrderItems (
    ORDERNUMBER VARCHAR(255),
    ORDERLINENUMBER INT,
    PRODUCTCODE VARCHAR(255),
    QUANTITYORDERED INT,
    PRICEEACH DECIMAL(10, 2),
    SALES DECIMAL(10, 2),
)

-- Insertion
-- Orders Table
INSERT INTO AutomotiveSalesData.dbo.Orders(ORDERNUMBER, ORDERDATE, DAYS_SINCE_LASTORDER, STATUS, CUSTOMERNAME)
SELECT ORDERNUMBER, ORDERDATE, DAYS_SINCE_LASTORDER, STATUS, CUSTOMERNAME
FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- Products Table
INSERT INTO AutomotiveSalesData.dbo.Products (PRODUCTCODE, PRODUCTLINE, MSRP)
SELECT PRODUCTCODE, PRODUCTLINE, MSRP
FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- Customers Table
INSERT INTO AutomotiveSalesData.dbo.Customers (CUSTOMERNAME, PHONE, ADDRESSLINE1, CITY, POSTALCODE, COUNTRY, CONTACTLASTNAME, CONTACTFIRSTNAME)
SELECT CUSTOMERNAME, PHONE, ADDRESSLINE1, CITY, POSTALCODE, COUNTRY, CONTACTLASTNAME, CONTACTFIRSTNAME
FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- OrderItems Table
INSERT INTO AutomotiveSalesData.dbo.OrderItems (ORDERNUMBER, ORDERLINENUMBER, PRODUCTCODE, QUANTITYORDERED, PRICEEACH, SALES)
SELECT ORDERNUMBER, ORDERLINENUMBER, PRODUCTCODE, QUANTITYORDERED, PRICEEACH, SALES
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
