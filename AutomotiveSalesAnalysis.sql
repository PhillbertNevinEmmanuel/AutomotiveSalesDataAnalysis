-- I want to look into the data first
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

/*
Apparently some of the column that contains numerical value has invalid data types
I need to change the data type of some column from varchar to int/float
*/
ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN ORDERNUMBER INT

ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN QUANTITYORDERED INT

ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN PRICEEACH FLOAT

ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN SALES FLOAT

-- this is for the ORDERDATE column
ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN ORDERDATE DATE

/*
I want to change it to DATE but the specific format is different from the expected format 
the SSMS needs. so i need to change the format of the date value in the ORDERDATE first
let's look into the orderdate column first
*/
SELECT ORDERDATE
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE ORDERDATE IS NOT NULL

-- now that we're sure we are updating the data in the right way, let's try updating it out
UPDATE AutomotiveSalesData.dbo.AutomotiveSalesData
SET ORDERDATE = CONVERT(DATE, ORDERDATE, 103)
WHERE ORDERDATE IS NOT NULL
-- after this check the ORDERDATE column again to make sure it is converted into the right data type

-- let's continue altering the data types
ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ALTER COLUMN DAYS_SINCE_LASTORDER INT

-- now i want to check any missing values
SELECT COUNT(*) AS missing_values
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE ORDERNUMBER IS NULL OR QUANTITYORDERED IS NULL OR PRICEEACH IS NULL OR ORDERLINENUMBER IS NULL OR SALES IS NULL OR ORDERDATE IS NULL OR DAYS_SINCE_LASTORDER IS NULL OR STATUS IS NULL OR PRODUCTLINE IS NULL OR MSRP IS NULL OR PRODUCTCODE IS NULL OR CUSTOMERNAME IS NULL OR PHONE IS NULL OR ADDRESSLINE1 IS NULL OR CITY IS NULL OR POSTALCODE IS NULL OR COUNTRY IS NULL OR CONTACTLASTNAME IS NULL OR CONTACTFIRSTNAME IS NULL OR DEALSIZE IS NULL

SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE ORDERNUMBER IS NULL OR QUANTITYORDERED IS NULL OR PRICEEACH IS NULL OR ORDERLINENUMBER IS NULL OR SALES IS NULL OR ORDERDATE IS NULL OR DAYS_SINCE_LASTORDER IS NULL OR STATUS IS NULL OR PRODUCTLINE IS NULL OR MSRP IS NULL OR PRODUCTCODE IS NULL OR CUSTOMERNAME IS NULL OR PHONE IS NULL OR ADDRESSLINE1 IS NULL OR CITY IS NULL OR POSTALCODE IS NULL OR COUNTRY IS NULL OR CONTACTLASTNAME IS NULL OR CONTACTFIRSTNAME IS NULL OR DEALSIZE IS NULL
-- there are 465 missing values in the postalcode column, since it's not important we can ignore it and move on

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 1
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

SELECT COUNT(ORDERNUMBER) AS count_order_number
FROM AutomotiveSalesData.dbo.AutomotiveSalesData

SELECT ORDERNUMBER, COUNT(*) AS count_order_number
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY ORDERNUMBER
HAVING COUNT(*) > 1

SELECT *
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE ORDERNUMBER = 10262


-- A. OVERVIEW
/* after changing the data types, i need to understand the dataset first
there are 20 columns within this table. i will try to explain it according to my own understanding

    ORDERNUMBER: Unique identifier for each order.
    QUANTITYORDERED: Quantity of products ordered.
    PRICEEACH: Price of each product.
    ORDERLINENUMBER: Line number of the order.
    SALES: Total sales amount for the order.
    ORDERDATE: Date of the order.
    DAYS_SINCE_LASTORDER: Number of days since the last order.
    STATUS: Status of the order.
    PRODUCTLINE: Product line/category.
    MSRP: Manufacturer's suggested retail price.
    PRODUCTCODE: Product code.
    CUSTOMERNAME: Customer's name.
    PHONE: Customer's phone number.
    ADDRESSLINE1: Customer's address.
    CITY: Customer's city.
    POSTALCODE: Customer's postal code.
    COUNTRY: Customer's country.
    CONTACTLASTNAME: Last name of the contact person.
    CONTACTFIRSTNAME: First name of the contact person.
    DEALSIZE: Size of the deal.

*/

-- I need to get the summary statistics for numerical columns
SELECT COUNT(*) AS total_rows,
AVG(QUANTITYORDERED) AS avg_item_sold, MAX(QUANTITYORDERED) AS top_item_sold, MIN(QUANTITYORDERED) AS min_item_sold, SUM(QUANTITYORDERED) AS total_lifetime_item_sold,
ROUND(AVG(SALES), 2) AS avg_revenue, MAX(SALES) AS top_sales, MIN(SALES) AS bottom_sales, SUM(SALES) AS total_lifetime_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
/*
total row = 2747
avg_productsold = 35
avg_revenue = 3553.05
top_sales = 14082.8
bottom_sales = 482.13
*/

-- there is a column named status, i need to understand this column better because it might give me some insight into the sales data
SELECT DISTINCT STATUS FROM AutomotiveSalesData.dbo.AutomotiveSalesData
/*
There are 6 order status:
1. Resolved
2. On Hold
3. Cancelled
4. Shipped
5. Disputed
6. In Process

I believe the data that we should analyze are the ones that has the status of either Shipped or Resolved.
while the other status is not complete so we should not analyze our sales data if they have the other stasuses as it might disrupt
or give us inaccurate insight towrads our report, given that they still have the risk of being cancelled or refunded.
*/

-- i want to see the count of how many orders of each status
SELECT STATUS, COUNT(STATUS) AS total_status_order
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY STATUS
ORDER BY total_status_order DESC

/*
1. Resolved		: 47
2. On Hold		: 44
3. Cancelled	: 60
4. Shipped		: 2541
5. Disputed		: 14
6. In Process	: 41
*/

-- now i want to see how much sales each status made
SELECT STATUS, SUM(SALES) AS total_revenue
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY STATUS
ORDER BY total_revenue DESC

/*
Total sales of each order status sort by total_revenue
1. Shipped		: 9019093.94
2. Cancelled	: 194487.48
3. On Hold		: 178979.19
4. Resolved		: 150718.28
5. In Process	: 144729.96
6. Disputed		: 72212.86
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 2
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- B. TIME SERIES ANALYSIS
-- i want to see the earliest and latest order dates
SELECT MIN(ORDERDATE) AS earliest_orderdate, MAX(ORDERDATE) AS latest_orderdate
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
/*
earliest order date is 2018-01-06
latest order date is 2020-05-17

the time range is from early January 2018 to Mid May 2020
*/

-- i want to see the breakdown of total sales per year and per month
-- per year
SELECT YEAR(ORDERDATE) AS year_of_year, SUM(SALES) AS total_sales, ROUND(AVG(SALES), 2) AS average_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS  = 'Resolved'
GROUP BY YEAR(ORDERDATE)
ORDER BY year_of_year
/*
2018 has a total sales of 3304303.14 and an average sales of 3526.47
2019 has a total sales of 4497887.78999999 and an average sales of 3516.72
2020 has a total sales of 1367621.29 and an average sales of 3676.4
*/

-- per month
SELECT YEAR(ORDERDATE) AS year_of_year, MONTH(ORDERDATE) AS month_of_month, SUM(SALES) AS total_sales, ROUND(AVG(SALES), 2) AS average_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS  = 'Resolved'
GROUP BY YEAR(ORDERDATE), MONTH(ORDERDATE)
ORDER BY year_of_year, month_of_month
/*
Month of month 2018 report
1. January: total sales 129753.6, average sales 3327.02
2. February: total sales 140836.19, average sales 3435.03
3. March: total sales 155809.32, average sales 3541.12
4. April: total sales 201609.55, average sales 3476.03
5. May: total sales 192673.11, average sales 3321.95
6. June: total sales 168082.56, average sales 3653.97
7. July: total sales 187731.88, average sales 3754.64
8. August: total sales 197809.3, average sales 3410.51
9. September: total sales 263973.36, average sales 3473.33
10. October: total sales 399742.03, average sales 3701.32
11. November: total sales 1029837.66, average sales 3479.18
12. December: total sales 236444.58, average sales 3753.09

Month of month 2019 report
1. January: total sales 292688.1, average sales 3526.36
2. February: total sales 311419.53, average sales 3621.16
3. March: total sales 205733.73, average sales 3673.82
4. April: total sales 206148.12, average sales 3221.06
5. May: total sales 228080.73, average sales 3801.35
6. June: total sales 186255.32, average sales 3386.46
7. July: total sales 327144.09, average sales 3594.99
8. August: total sales 461501.27, average sales 3469.93
9. September: total sales 320750.91, average sales 3376.33
10. October: total sales 552924.25, average sales 3477.51
11. November: total sales 1032439.08, average sales 3597.35
12. December: total sales 372802.66, average sales 3389.12

Month of month 2020 report
1. January: total sales 339543.42, average sales 3429.73
2. February: total sales 303982.56, average sales 3618.84
3. March: total sales 374262.76, average sales 3530.78
4. April: total sales 131218.33, average sales 4524.77
5. May: total sales 218614.22, average sales 4048.41
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 3
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- C. PRODUCT MIX ANALYSIS
-- I want to see the summary product types based on the productline
SELECT PRODUCTLINE AS product_line, COUNT(DISTINCT PRODUCTCODE) AS product_types
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY PRODUCTLINE
ORDER BY product_types DESC
/*
there are 7 productlines: Classic Cars, Vintage Cars, Motorcycles, Planes, Trucks and Buses, Ships, Trains
Classic Cars Product Line has 37 product_types
Vintage Cars Product Line has 24 product_types
Motorcycles Product Line has 13 product_types
Planes Product Line has 12 product_types
Trucks and Buses Product Line has 11 product_types
Ships Product Line has 9 product_types
Trains Product Line has 3 product_types
*/

-- now I want to see the sales data based on the product line. how many revenue it generated and how many items ordered.
SELECT PRODUCTLINE AS product_line, SUM(QUANTITYORDERED) AS total_items_ordered, SUM(SALES) AS total_revenue, ROUND(AVG(SALES), 2) AS avg_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY PRODUCTLINE
ORDER BY total_revenue DESC

/*
1. Classic Cars Product Line has revenue of 3650812.55 with average sales of 4038.51, and 31630 items ordered
2. Vintage Cars Product Line has finished order, revenue of 1676652.03 with average sales of 3110.67, and 18588 items ordered
3. Motorcycles Product Line has revenue of 1066697.68 with average sales of 3485.94, and 10772 items ordered
4. Trucks and Buses Product Line has revenue of 1048339.49 with average sales of 3744.07, and 10014 items ordered
5. Planes Product Line has revenue of 895319.34 with average sales of 3186.19, and 9740 items ordered
6. Ships Product Line has revenue of 616638.56 with average sales of 3037.63, and 7058 items ordered
7. Trains Product Line has revenue of 215352.57 with average sales of 2871.37, and 2622 items ordered
*/

-- now i want to see how many revenue, average sales and quantity order of each productcode from each product line has generated
SELECT PRODUCTLINE, PRODUCTCODE, SUM(QUANTITYORDERED) AS total_quantity_ordered, SUM(SALES) AS total_revenue, ROUND(AVG(SALES), 2) AS avg_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY PRODUCTLINE, PRODUCTCODE
ORDER BY PRODUCTLINE

-- By assuming that our profit is priceeach - 60% of MSRP, i want to see our profit
WITH ProductSalesProfitSummary AS(
	SELECT PRODUCTLINE, PRODUCTCODE,
	SUM(PRICEEACH * QUANTITYORDERED) AS sales,
	SUM(MSRP * QUANTITYORDERED) AS msrp
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
	GROUP BY PRODUCTLINE, PRODUCTCODE
)
SELECT PRODUCTLINE, PRODUCTCODE,
SUM(sales - (0.65 * msrp)) AS profit
FROM ProductSalesProfitSummary
GROUP BY PRODUCTLINE, PRODUCTCODE
ORDER BY PRODUCTLINE

-- let's see the overall top selling products
SELECT TOP 5 PRODUCTCODE, PRODUCTLINE, SUM(QUANTITYORDERED) as total_items_ordered, SUM(SALES) AS total_revenue, ROUND(AVG(SALES), 2) AS avg_sales
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY PRODUCTCODE, PRODUCTLINE
ORDER BY total_revenue DESC
/*
the 5 overall top selling products are:
1. S18_3232 from Classic Cars product line, it has generated revenue of 270803.46 with average sales of 5641.73 and 1666 items ordered
2. S12_1108 from Classic Cars product line, it has generated revenue of 168585.32 with average sales of 6484.05 and 973 items bought
3. S10_1949 from Classic Cars product line, it has generated revenue of 167814.23 with average sales of 6712.57 and 849 items bought
4. S18_2238 from Classic Cars product line, it has generated revenue of 149305.91 with average sales of 5742.53 and 938 items bought
5. S10_4698 from Motorcycles product line, it has generated revenue of 148984.32 with average sales of 6477.58 and 794 items bought
*/

-- i want to see top 5 selling products from each productline, let's start with ones that generated the most revenue
-- i want to try using rank function and partition by inside a CTE to create a rank and delimit it into 5 maximum productcode of each productline category
WITH ProductLineSales AS(
	SELECT PRODUCTLINE, PRODUCTCODE, SUM(SALES) AS total_revenue, SUM(QUANTITYORDERED) AS total_items_ordered
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
	GROUP BY PRODUCTLINE, PRODUCTCODE
),
RankedProductLine AS(
	SELECT PRODUCTLINE, PRODUCTCODE, total_revenue, total_items_ordered,
	ROW_NUMBER() OVER (PARTITION BY PRODUCTLINE ORDER BY total_revenue DESC) AS product_code_rank
	FROM ProductLineSales
)
SELECT PRODUCTLINE, PRODUCTCODE, total_revenue, total_items_ordered
FROM RankedProductLine
WHERE product_code_rank BETWEEN 1 AND 5
/*
I.		Productline Classic Cars:
		1. S18_3232 with 270803.46 total revenue
		2. S12_1108 with 168585.32 total revenue
		3. S12_1108 with 168585.32 total revenue
		4. S12_1108 with 168585.32 total revenue
		5. S12_1108 with 168585.32 total revenue

II.		Motorcycles
		1. S10_4698 with 270803.46 total revenue
		2. S12_2823 with 126290.54 total revenue
		3. S10_2016 with 92087.36 total revenue
		4. S24_1578 with 85983.07 total revenue
		5. S32_1374 with 84329.23 total revenue

III.	Planes
		1. S18_1662 with 127090.29 total revenue
		2. S700_2834 with 100091.88 total revenue
		3. S700_2466 with 83704.47 total revenue
		4. S700_1691 with 79456.99 total revenue
		5. S700_4002 with 71656.78 total revenue

IV.		Ships
		1. S24_2011 with 97669.14 total revenue
		2. S700_3505 with 79478.17 total revenue
		3. S700_3962 with 71876.78 total revenue
		4. S700_2047 with 67397.74 total revenue
		5. S700_2610 with 66105.63 total revenue

V.		Trains
		1. S18_3259 with 79566.14 total revenue
		2. S50_1514 with 71495.78 total revenue
		3. S32_3207 with 64290.65 total revenue
		
VI.		Trucks and Buses
		1. S12_1666 with 122497.43 total revenue
		2. S24_2300 with 114234.85 total revenue
		3. S18_4600 with 112634.45 total revenue
		4. S12_4473 with 111189.34 total revenue
		5. S50_1392 with 106883.19 total revenue

VI.		Vintage Cars
		1. S18_2795 with 112556.43 total revenue
		2. S18_1749 with 102767.52 total revenue
		3. S18_2325 with 99439 total revenue
		4. S18_3140 with 97697.78 total revenue
		5. S18_2949 with 91611.54 total revenue
*/

-- now i want to see which product from each product line get ordered the most (quantity)
WITH ProductLineQuantity AS(
	SELECT PRODUCTLINE, PRODUCTCODE, SUM(QUANTITYORDERED) as total_quantity_ordered, SUM(SALES) as total_revenue
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
	GROUP BY PRODUCTLINE, PRODUCTCODE
),
RankedProductLine AS(
	SELECT PRODUCTLINE, PRODUCTCODE, total_quantity_ordered, total_revenue,
	ROW_NUMBER() OVER (PARTITION BY PRODUCTLINE ORDER BY total_quantity_ordered DESC) AS product_code_rank
	FROM ProductLineQuantity
)
SELECT PRODUCTLINE, PRODUCTCODE, total_quantity_ordered, total_revenue
FROM RankedProductLine
WHERE product_code_rank BETWEEN 1 AND 5
/*
I.		Productline Classic Cars:
		1. S18_3232 with 1666 total items ordered
		2. S24_3856 with 978 total items ordered
		3. S12_1108 with 973 total items ordered
		4. S12_1108 with 952 total items ordered
		5. S12_1108 with 938 total items ordered

II.		Motorcycles
		1. S24_2000 with 904 total items ordered
		2. S50_4713 with 881 total items ordered
		3. S12_2823 with 880 total items ordered
		4. S18_3782 with 875 total items ordered
		5. S10_2016 with 822 total items ordered

III.	Planes
		1. S700_4002 with 966 total items ordered
		2. S24_3949 with 896 total items ordered
		3. S18_1662 with 848 total items ordered
		4. S700_2834 with 840 total items ordered
		5. S700_3167 with 834 total items ordered

IV.		Ships
		1. S700_2610 with 881 total items ordered
		2. S700_3505 with 835 total items ordered
		3. S24_2011 with 828 total items ordered
		4. S72_3212 with 819 total items ordered
		5. S700_1138 with 786 total items ordered

V.		Trains
		1. S50_1514 with 945 total items ordered
		2. S32_3207 with 907 total items ordered
		3. S18_3259 with 770 total items ordered
		
VI.		Trucks and Buses
		1. S12_4473 with 991 total items ordered
		2. S50_1392 with 961 total items ordered
		3. S32_2509 with 944 total items ordered
		4. S18_4600 with 944 total items ordered
		5. S18_2432 with 910 total items ordered

VI.		Vintage Cars
		1. S18_2949 with 909 total items ordered
		2. S18_4668 with 901 total items ordered
		3. S50_1341 with 894 total items ordered
		4. S18_1342 with 865 total items ordered
		5. S18_3856 with 858 total items ordered
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 4
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- D. GEOGRAPHIC ANALYSIS
-- now i want to see the country with biggest sales, and their average sales too
SELECT COUNTRY, SUM(SALES) AS total_revenue, ROUND(AVG(SALES), 2) AS avg_revenue
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY COUNTRY
ORDER BY total_revenue DESC
/*
there are 19 countries listed on the sales report:
1. USA, total sales 3144070.5, average sales 3605.59
2. Spain, total sales 1098721.03, average sales 3499.11
3. France, total sales 1067131.83, average sales 3545.29
4. Australia, total sales 572273.58, average sales 3426.79
5. UK, total sales 428472.21, average sales 3295.94
6. Italy, total sales 374674.31, average sales 3315.7
7. Finland, total sales 329581.91, average sales 3582.41
8. Norway, total sales 307463.7, average sales 3617.22
9. Singapore, total sales 288488.41, average sales 3651.75
10. Canada, total sales 224078.56, average sales 3201.12
11. Germany, total sales 220472.09, average sales 3556
12. Denmark, total sales 219624.28, average sales 3651.75
13. Austria, total sales 288488.41, average sales 3660.4
14. Japan, total sales 188167.81, average sales 3618.61
15. Sweden, total sales 135043.08, average sales 3858.37
16. Switzerland, total sales 117713.56, average sales 3797.21
17. Belgium, total sales 100000.67, average sales 3571.45
18. Philippines, total sales 94015.73, average sales 3615.99
19. Ireland, total sales 57756.43, average sales 3609.78
*/

-- I want to see what are the 5 top selling products and where are they get sold the most
SELECT TOP 5 COUNTRY, PRODUCTCODE, PRODUCTLINE,  SUM(QUANTITYORDERED) AS total_product_ordered, SUM(SALES) AS total_revenue
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY COUNTRY, PRODUCTCODE, PRODUCTLINE
ORDER BY total_revenue DESC
/*
Top 5 selling products are from USA, named:
1. S18_3232 from Classic Cars Productline with 471 orders and 76987.85 total revenue
2. S18_2238 from Classic Cars Productline with 466 orders and 74791.3 total revenue
3. S10_4698 from Motorcycles Productline with 356 orders and 66894.08 total revenue
4. S10_1949 from Classic Cars Productline with 340 orders and 64096.64 total revenue
5. S12_2823 from Motorcycles Productline with 436 orders and 63597.2 total revenue
*/

-- I want to see what are the 5 top seling product from each country
WITH CountryProductSales AS(
	SELECT COUNTRY, PRODUCTLINE, PRODUCTCODE, SUM(SALES) as total_revenue
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
	GROUP BY COUNTRY, PRODUCTLINE, PRODUCTCODE
),
RankedProductSales AS(
	SELECT COUNTRY, PRODUCTLINE, PRODUCTCODE, total_revenue,
	ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY total_revenue DESC) AS product_code_rank
	FROM CountryProductSales
)
SELECT COUNTRY, PRODUCTCODE, PRODUCTLINE, total_revenue
FROM RankedProductSales
WHERE product_code_rank BETWEEN 1 AND 5

/*
1.	Australia
	S12_1666 from Trucks and Buses Product Line with 25433.31 total revenue
	S18_2949 from Vintage Cars Product Line with 22993.7 total revenue
	S18_2795 from Vintage Cars Product Line with 22930.54 total revenue
	S10_4698 from Motorcycles Product Line with 22873.27 total revenue
	S18_3482 from Classic Cars Product Line with 19420.24 total revenue

2.	Austria
	S24_3856 from Classic Cars Product Line with 13059.56 total revenue
	S12_4675 from Classic Cars Product Line with 12359.74 total revenue
	S12_3380 from Classic Cars Product Line with 10777.81 total revenue
	S12_2823 from Motorcycles Product Line with 8118.55 total revenue
	S10_1678 from Motorcycles Product Line with 7737.93 total revenue

3.	Belgium
	S18_3856 from Vintage Cars Product Line with 9813.95 total revenue
	S24_2011 from Ships Product Line with 9589.39 total revenue
	S18_3140 from Vintage Cars Product Line with 9443.78 total revenue
	S18_3259 from Trains Product Line with 7306 total revenue
	S18_3232 from Classic Cars Product Line with 6275.72 total revenue

4.	Canada
	S10_1949 from Classic Cars Product Line with 13205.12 total revenue
	S12_1666 from Trucks and Buses Product Line with 12957.46 total revenue
	S10_4962 from Classic Cars Product Line with 11105.73 total revenue
	S700_2824 from Classic Cars Product Line with 10422.59 total revenue
	S18_3232 from Classic Cars Product Line with 10053.7 total revenue

5.	Denmark
	S12_1108 from Classic Cars Product Line with 16665.8 total revenue
	S12_3891 from Classic Cars Product Line with 11479.85 total revenue
	S700_1938 from Ships Product Line with 7256.61 total revenue
	S10_4757 from Classic Cars Product Line with 7208 total revenue
	S18_3259 from Trains Product Line with 6811.8 total revenue

6.	Finland
	S18_3232 from Classic Cars Product Line with 22918.41 total revenue
	S18_2238 from Classic Cars Product Line with 13049.44 total revenue
	S18_2319 from Trucks and Buses Product Line with 11700.2 total revenue
	S12_4675 from Classic Cars Product Line with 11209.58 total revenue
	S12_1108 from Classic Cars Product Line with 10606.2 total revenue

7.	France
	S12_2823 from Motorcycles Product Line with 32469.62 total revenue
	S18_3232 from Classic Cars Product Line with 28428.6 total revenue
	S50_4713 from Motorcycles Product Line with 25164.7 total revenue
	S10_4698 from Motorcycles Product Line with 22818.8 total revenue
	S700_2824 from Classic Cars Product Line with 20839.24 total revenue

8.	Germany
	S12_1099 from Classic Cars Product Line with 16297.41 total revenue
	S18_3482 from Classic Cars Product Line with 13467.19 total revenue
	S12_3380 from Classic Cars Product Line with 12674.92 total revenue
	S18_4721 from Classic Cars Product Line with 9594.56 total revenue
	S18_3278 from Classic Cars Product Line with 9447.95 total revenue

9.	Ireland
	S18_4027 from Classic Cars Product Line with 8258 total revenue
	S12_1108 from Classic Cars Product Line with 7181.44 total revenue
	S12_3891 from Classic Cars Product Line with 5045.22 total revenue
	S24_4048 from Classic Cars Product Line with 5032.74 total revenue
	S12_3148 from Classic Cars Product Line with 4713.6 total revenue

10.	Italy
	S12_3891 from Classic Cars Product Line with 16125.5 total revenue
	S12_1108 from Classic Cars Product Line with 15886.06 total revenue
	S700_2834 from Planes Product Line with 13701.59 total revenue
	S12_3148 from Classic Cars Product Line with 12620.93 total revenue
	S24_1785 from Planes Product Line with 10761.63 total revenue

11.	Japan
	S24_3151 from Vintage Cars Product Line with 10758 total revenue
	S10_4698 from Motorcycles Product Line with 9113.53 total revenue
	S10_1949 from Classic Cars Product Line with 7680.64 total revenue
	S18_4027 from Classic Cars Product Line with 7031.52 total revenue
	S12_1666 from Trucks and Buses Product Line with 6668.24 total revenue

12.	Norway
	S18_3685 from Classic Cars Product Line with 12231.96 total revenue
	S24_3856 from Motorcycles Product Line with 11585.25 total revenue
	S18_1129 from Classic Cars Product Line with 11335.94 total revenue
	S18_1984 from Classic Cars Product Line with 10774.12 total revenue
	S18_3232 from Trucks and Buses Product Line with 10336.41 total revenue

13.	Philippines
	S18_4721 from Classic Cars Product Line with 11666.12 total revenue
	S18_3482 from Classic Cars Product Line with 8454.78 total revenue
	S18_1662 from Planes Product Line with 7483.98 total revenue
	S12_3380 from Classic Cars Product Line with 6130.35 total revenue
	S24_2360 from Motorcycles Product Line with 5463.71 total revenue

14.	Singapore
	S18_4600 from Trucks and Buses Product Line with 15642.72 total revenue
	S12_1108 from Classic Cars Product Line with 14628.9 total revenue
	S10_4962 from Classic Cars Product Line with 14245.06 total revenue
	S12_4473 from Trucks and Buses Product Line with 13366.8 total revenue
	S24_2300 from Trucks and Buses Product Line with 13096.26 total revenue

15. Spain
	S18_3232 from Classic Cars Product Line with 55046.38 total revenue
	S24_2300 from Trucks and Buses Product Line with 30596.76 total revenue
	S18_2238 from Classic Cars Line with 26529.21 total revenue
	S24_4048 from Classic Cars Product Line with 26461.6 total revenue
	S18_2795 from Vintage Cars Product Line with 23968.02 total revenue

16.	Sweden
	S10_1949 from Classic Cars Product Line with 14345.3 total revenue
	S12_1099 from Classic Cars Product Line with 9451.15 total revenue
	S18_2949 from Vintage Cars Product Line with 8253.68 total revenue
	S18_2625 from Motorcycles Product Line with 6981 total revenue
	S12_3380 from Classic Cars Product Line with 6659.8 total revenue

17. Switzerland
	S18_3232 from Classic Cars Product Line with 12260.38 total revenue
	S18_3482 from Classic Cars Product Line with 11325.68 total revenue
	S18_1129 from Classic Cars Product Line with 11028.6 total revenue
	S18_4721 from Classic Cars Product Line with 9560.47 total revenue
	S24_3856 from Classic Cars Product Line with 8847.32 total revenue

18.	UK
	S18_4409 from Vintage Cars Product Line with 16803.84 total revenue
	S24_2887 from Classic Cars Product Line with 16141.12 total revenue
	S24_2011 from Ships Product Line with 14888.09 total revenue
	S18_1662 from Planes Product Line with 13590.21 total revenue
	S18_1749 from Vintage Cars Product Line with 13379 total revenue

19. USA
	S18_3232 from Classic Cars Product Line with 76987.85 total revenue
	S18_2238 from Classic Cars Product Line with 74791.3 total revenue
	S10_4698 from Motorcycles Product Line with 66894.08 total revenue
	S10_1949 from Classic Cars Product Line with 64096.64 total revenue
	S12_2823 from Motorcycles Product Line with 63597.2 total revenue
*/

-- i want to see top 5 most ordered products from each country
WITH CountryProductOrderQuantity AS(
	SELECT COUNTRY, PRODUCTLINE, PRODUCTCODE, SUM(QUANTITYORDERED) as total_quantity_ordered
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
	GROUP BY COUNTRY, PRODUCTLINE, PRODUCTCODE
),
RankedProductSales AS(
	SELECT COUNTRY, PRODUCTLINE, PRODUCTCODE, total_quantity_ordered,
	ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY total_quantity_ordered DESC) AS product_code_rank
	FROM CountryProductOrderQuantity
)
SELECT COUNTRY, PRODUCTCODE, PRODUCTLINE, total_quantity_ordered
FROM RankedProductSales
WHERE product_code_rank BETWEEN 1 AND 5

/*
i'm too lazy to fill this one you fill this one out, the function is correct anyway
1.	Australia
	

2.	Austria
	

3.	Belgium
	

4.	Canada
	

5.	Denmark
	

6.	Finland
	

7.	France
	

8.	Germany
	

9.	Ireland
	

10.	Italy
	

11.	Japan
	

12.	Norway
	

13.	Philippines
	

14.	Singapore
	

15. Spain
	

16.	Sweden
	

17. Switzerland
	

18.	UK
	

19. USA
	
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 5
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- E. CUSTOMER SEGMENTATION AND BEHAVIOR ANALYSIS
-- i want to see top 5 biggest customer
SELECT TOP 5 CUSTOMERNAME, COUNTRY, COUNT(ORDERNUMBER) AS order_count, SUM(SALES) AS revenue, SUM(QUANTITYORDERED) AS total_items_ordered
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY CUSTOMERNAME, COUNTRY
ORDER BY revenue DESC
/*
Top 5 customers are 
1. Euro Shopping Channel from Spain, ordered 231 times with revenue generated of 795328.22 and 8194 products bought
2. Mini Gifts Distributors Ltd. from USA, ordered 178 times with revenue generated of 647596.31 and 6291 products bought
3. Australian Collectors, Co. from Australia, ordered 55 times with revenue generated of200995.41 and 1926 products bought
4. Muscle Machine Inc from USA, ordered 48 times with revenue generated of 197736.94 and 1775 products bought
5. Dragon Souveniers, Ltd. from Singapore, ordered 43 times with revenue generated of 172989.68 and 1524 products bought
*/

-- I want to classify customers as new or returning customer based on their order history.
SELECT CUSTOMERNAME, COUNTRY, COUNT(DISTINCT ORDERNUMBER) AS order_count,
    CASE
        WHEN COUNT(DISTINCT ORDERNUMBER) <= 1 THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS customer_type
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY CUSTOMERNAME, COUNTRY
ORDER BY order_count DESC

-- now i want to count how many customers are returning customer and how many are new customer
SELECT customer_type, COUNT(*) AS customer_count
FROM (
    SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS order_count,
        CASE
            WHEN COUNT(DISTINCT ORDERNUMBER) = 1 THEN 'New Customer'
            ELSE 'Returning Customer'
        END AS customer_type
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
) AS ReturningVsNewcomer
GROUP BY customer_type

-- let's see if i can get the customer retention rate
SELECT
    COUNT(DISTINCT 
		CASE
			WHEN total_orders >= 2
			THEN CUSTOMERNAME
		END) AS repeat_customers,
    COUNT(DISTINCT CUSTOMERNAME) AS total_customers,
    (COUNT(DISTINCT
		CASE
			WHEN total_orders >= 2
			THEN CUSTOMERNAME
		END)
		/
		COUNT(DISTINCT CUSTOMERNAME)) * 100 AS retention_rate
FROM (
    SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS total_orders
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
) AS customer_orders

-- apparently the customer retention rate calculation gives 0 because the calculation is wrong and it keeps throwing 0 so it keeps getting divided by 0
SELECT
	COUNT(DISTINCT
		CASE
			WHEN total_orders >= 2
			THEN CUSTOMERNAME
		END) AS repeat_customers,
	COUNT(DISTINCT CUSTOMERNAME) AS total_customers,
	(COUNT(DISTINCT
		CASE
			WHEN total_orders >= 2 
			THEN CUSTOMERNAME
		END) * 1.0 
		/
		NULLIF(COUNT(DISTINCT CUSTOMERNAME), 0)) * 100 AS retention_rate
FROM (
    SELECT CUSTOMERNAME, COUNT(DISTINCT ORDERNUMBER) AS total_orders
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
) AS customer_orders

/*
We have a staggering retention rate of 98.8%!
*/

-- customer tenure calculation
SELECT CUSTOMERNAME, MIN(ORDERDATE) AS first_order_date, MAX(ORDERDATE) AS last_order_date, DATEDIFF(DAY, MIN(ORDERDATE), MAX(ORDERDATE)) AS customer_tenure_days
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY CUSTOMERNAME
ORDER BY customer_tenure_days DESC

-- i want to create a customer tenure days column
ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ADD CUSTOMERTENUREDAYS INT

UPDATE AutomotiveSalesData.dbo.AutomotiveSalesData
SET CUSTOMERTENUREDAYS = DATEDIFF(DAY,(
		SELECT MIN(ORDERDATE)
		FROM AutomotiveSalesData.dbo.AutomotiveSalesData asd
		WHERE asd.CUSTOMERNAME = AutomotiveSalesData.dbo.AutomotiveSalesData.CUSTOMERNAME
	),(
		SELECT MAX(ORDERDATE)
		FROM AutomotiveSalesData.dbo.AutomotiveSalesData asd
		WHERE asd.CUSTOMERNAME = AutomotiveSalesData.dbo.AutomotiveSalesData.CUSTOMERNAME
	)
)

SELECT CUSTOMERNAME, MIN(ORDERDATE) AS first_order_date, MAX(ORDERDATE) AS last_order_date, CUSTOMERTENUREDAYS
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY CUSTOMERNAME, CUSTOMERTENUREDAYS
ORDER BY CUSTOMERTENUREDAYS DESC

-- average of customer tenure days logic
WITH CustomerTenure AS(
	SELECT DATEDIFF(DAY, MIN(ORDERDATE), MAX(ORDERDATE)) AS customer_tenure_days
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	GROUP BY CUSTOMERNAME
)
SELECT AVG(customer_tenure_days) as avg_customer_tenure_days
FROM CustomerTenure

-- let's try to calculate it using our new column
WITH CustomerTenure AS(
	SELECT CUSTOMERTENUREDAYS AS customer_tenure_days
	FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	GROUP BY CUSTOMERNAME, CUSTOMERTENUREDAYS
)
SELECT AVG(customer_tenure_days) AS avg_customer_tenure_days
FROM CustomerTenure

-- I want to classify customers based on their dealsize
SELECT CUSTOMERNAME, DEALSIZE, COUNT(ORDERNUMBER) AS order_count
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
GROUP BY CUSTOMERNAME, DEALSIZE
ORDER BY CUSTOMERNAME, DEALSIZE

-- I want to see which customer has the most disputed and cancelled order status so we let the management know what to do with those customers

SELECT CUSTOMERNAME, STATUS, SUM(QUANTITYORDERED) AS total_order, SUM(SALES) AS total_revenue
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE STATUS = 'Disputed' OR STATUS = 'Cancelled'
GROUP BY CUSTOMERNAME, STATUS
ORDER BY total_order DESC, total_revenue DESC

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 6
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- F. CORRELATION ANALYSIS
-- I want to see the correlation between sales and seasonality per month using pearson correlation method
-- so first i need to extract seasonality component (month of ORDERDATE) and average sales
SELECT MONTH(ORDERDATE) AS order_month, SUM(SALES) AS total_sales
INTO #TempSalesByMonth
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY MONTH(ORDERDATE)

-- start the declaration
DECLARE @mean_sales FLOAT, @mean_seasonality FLOAT, @cov_sales_seasonality FLOAT, @std_dev_sales FLOAT, @std_dev_seasonality FLOAT, @correlation FLOAT
-- Calculate mean sales and seasonality
SELECT @mean_sales = AVG(total_sales), @mean_seasonality = AVG(order_month) FROM #TempSalesByMonth
-- Calculate covariance
SELECT @cov_sales_seasonality = SUM((total_sales - @mean_sales) * (order_month - @mean_seasonality)) / COUNT(*) FROM #TempSalesByMonth
-- Calculate standard deviation
SELECT @std_dev_sales = SQRT(SUM(POWER(total_sales - @mean_sales, 2)) / COUNT(*)),
       @std_dev_seasonality = SQRT(SUM(POWER(order_month - @mean_seasonality, 2)) / COUNT(*))
FROM #TempSalesByMonth
-- Calculating correlation
SET @correlation = @cov_sales_seasonality / (@std_dev_sales * @std_dev_seasonality)
SELECT ROUND(@correlation, 2) AS correlation_sales_seasonality
DROP TABLE #TempSalesByMonth
/*
there is a low positive correlation between sales and seasonality at 0.32
we believe the correlation between sales in automotive industry and seasonality is low, there are many factors that could be the cause behind it
but i don't intend to list it because i have no idea what's behind it.
*/

-- Now i want to analyze the correlation between sales and customer tenure
-- Step 1: Calculate total sales for each customer
WITH CustomerTotalSales AS (
    SELECT CUSTOMERNAME, SUM(SALES) AS total_sales
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
    GROUP BY CUSTOMERNAME
),
-- Step 2: Determine customer tenure for each customer
CustomerTenure AS (
    SELECT CUSTOMERNAME, DATEDIFF(DAY, MIN(ORDERDATE), MAX(ORDERDATE)) AS customer_tenure_days
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
    GROUP BY CUSTOMERNAME
)
-- Step 3: Calculate correlation between total sales and customer tenure
SELECT ROUND((COUNT(*) * SUM(ct.total_sales * t.customer_tenure_days) - SUM(ct.total_sales) * SUM(t.customer_tenure_days)) /
		(SQRT((COUNT(*) * SUM(POWER(ct.total_sales, 2)) - POWER(SUM(ct.total_sales), 2)) * (COUNT(*) * SUM(POWER(t.customer_tenure_days, 2)) - POWER(SUM(t.customer_tenure_days), 2)))), 2) AS correlation_sales_tenure
FROM CustomerTotalSales ct
JOIN CustomerTenure t
ON ct.CUSTOMERNAME = t.CUSTOMERNAME

-- i want to check the exact difference between the dealsizes and compare it to each other
SELECT DISTINCT DEALSIZE FROM AutomotiveSalesData.dbo.AutomotiveSalesData
/*
there are 3 types of dealsize: Small, Medium and Large
dealsize is categorized based on how much revenue it generates
*/

-- i want to see where is the turning point that changes between small, medium and large dealsize
SELECT MIN(SALES) AS minimum_small_dealsize, MAX(SALES) AS maximum_small_dealsize FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE DEALSIZE = 'Small'

SELECT MIN(SALES) AS minimum_medium_dealsize, MAX(SALES) AS maximum_medium_dealsize FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE DEALSIZE = 'Medium'

SELECT MIN(SALES) AS minimum_large_dealsize, MAX(SALES) AS maximum_large_dealsize FROM AutomotiveSalesData.dbo.AutomotiveSalesData
WHERE DEALSIZE = 'Large'
/*
the small dealsize is sales between 0-3000
the medium dealsize is sales between 3000-7000
the large dealsize is sales >7000
*/

-- checking the distribution of deal sizes
SELECT DEALSIZE, COUNT(DEALSIZE) AS total_orders, SUM(SALES) AS total_revenue
FROM AutomotiveSalesData.dbo.AutomotiveSalesData
GROUP BY DEALSIZE
/*
1. there are 152 large orders with 1258956.4 generated revenue
2. there are 1349 medium orders with 5931231.47 generated revenue
3. there are 1246 small orders with 2570033.84 generated revenue
*/

-- I want to analyze the correlation between dealsize and the customer tenure

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- checkpoint 7
SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData

-- G. CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- I want to calculate the customer lifetime value analysis, the formula for customer lifetime value analysis is:
-- CLV=AVG(sales) AS APV * total_orders AS PF * AVG(customer_tenure_days)/365.0 AS CLS

WITH CustomerAveragePurchaseValue AS (
    SELECT CUSTOMERNAME, AVG(SALES) AS avg_purchase_value
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
),
CustomerOrders AS (
    SELECT CUSTOMERNAME, COUNT(ORDERNUMBER) AS total_orders
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
),
CustomerTenure AS (
    SELECT CUSTOMERNAME, DATEDIFF(DAY, MIN(ORDERDATE), MAX(ORDERDATE)) AS customer_tenure_days
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
)
SELECT
	capv.CUSTOMERNAME,
	AVG(capv.avg_purchase_value) as avg_purchase_value,
	co.total_orders AS purchase_frequency,
	AVG(ct.customer_tenure_days) / 365.0 AS customer_lifespan_years,
    ROUND(AVG(capv.avg_purchase_value) * co.total_orders * (AVG(ct.customer_tenure_days) / 365.0), 2) AS clv
FROM CustomerAveragePurchaseValue AS capv
JOIN CustomerOrders AS co ON capv.CUSTOMERNAME = co.CUSTOMERNAME
JOIN CustomerTenure AS ct ON capv.CUSTOMERNAME = ct.CUSTOMERNAME
GROUP BY capv.CUSTOMERNAME, co.total_orders
ORDER BY clv DESC

-- now that we have the right customer lifetime analysis formula, let's insert it into a new column called clv

ALTER TABLE AutomotiveSalesData.dbo.AutomotiveSalesData
ADD CUSTOMERLIFETIMEVALUE FLOAT

WITH CustomerAveragePurchaseValue AS (
    SELECT CUSTOMERNAME, AVG(SALES) AS avg_purchase_value
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
),
CustomerOrders AS (
    SELECT CUSTOMERNAME, COUNT(ORDERNUMBER) AS total_orders
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
),
CustomerTenure AS (
    SELECT CUSTOMERNAME, DATEDIFF(DAY, MIN(ORDERDATE), MAX(ORDERDATE)) AS customer_tenure_days
    FROM AutomotiveSalesData.dbo.AutomotiveSalesData
	WHERE STATUS = 'Shipped' OR STATUS = 'Resolved'
    GROUP BY CUSTOMERNAME
),
CLV AS(
	SELECT capv.CUSTOMERNAME,
	AVG(capv.avg_purchase_value) AS avg_purchase_value,
	co.total_orders AS purchase_frequency,
	AVG(ct.customer_tenure_days) / 365.0 AS customer_lifespan_years
	FROM CustomerAveragePurchaseValue AS capv
	JOIN CustomerOrders co ON capv.CUSTOMERNAME = co.CUSTOMERNAME
	JOIN CustomerTenure ct ON capv.CUSTOMERNAME = ct.CUSTOMERNAME
	GROUP BY capv.CUSTOMERNAME, co.total_orders
)
UPDATE asd
SET asd.CUSTOMERLIFETIMEVALUE  = ROUND(clv.avg_purchase_value * clv.purchase_frequency * (clv.customer_lifespan_years), 2)
FROM AutomotiveSalesData asd
JOIN CLV clv ON asd.CUSTOMERNAME = clv.CUSTOMERNAME

-- let's check our whole data and the count distinct of customername and customer lifetimevalue
SELECT COUNT(DISTINCT CUSTOMERNAME) as count_customername, COUNT(DISTINCT CUSTOMERLIFETIMEVALUE) count_clv FROM AutomotiveSalesData.dbo.AutomotiveSalesData

SELECT * FROM AutomotiveSalesData.dbo.AutomotiveSalesData