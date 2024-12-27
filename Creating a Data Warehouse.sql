-- Q1

 -- 4 Step Dimensional Model
 -- Step 1: Sales Performance
 -- Step 2: Transaction Fact Table
 -- Step 3: Date, Order, Customer
 -- Step 4: TotalNoOfReturnCust, TotalNoOfCust, TotalNoOfOrder

-- Create Dimension Tables
CREATE TABLE DateDim (
    DateKey int PRIMARY KEY,
	Date DATE,
    Year int,
    Quarter int,
    Month int,
    Day int
);

CREATE TABLE CustomerDim (
    CustomerKey int PRIMARY KEY,       
    CustomerID int,                     
    FirstName varchar(100),
	LastName varchar(100),
    Address varchar(100),
	City varchar(100),
    State varchar(100),
    ZipCode varchar(20),
    Phone varchar(100),
    Email varchar(100)                       
);

-- Create Order Fact Table 
CREATE TABLE FactOrders (
    OrderID INT PRIMARY KEY,
    CustomerKey INT,
    DateKey INT,
    Orders INT,
    FOREIGN KEY (CustomerKey) REFERENCES CustomerDim(CustomerKey),
    FOREIGN KEY (DateKey) REFERENCES DateDim(DateKey)
);


-- 1) Yearly Customer Retention (total number of returning customers divided by total number of all customers)

WITH ReturningCustomers AS (
    -- Count of returning customers for each year
    SELECT D.Year, COUNT(DISTINCT F.CustomerKey) AS ReturningCount
    FROM FactOrders F
    JOIN DateDim D ON F.DateKey = D.DateKey
    GROUP BY D.Year
),
TotalCustomers AS (
    -- Count of total customers for each year
    SELECT D.Year, COUNT(DISTINCT C.CustomerKey) AS TotalCount
    FROM CustomerDim C
    JOIN FactOrders F ON C.CustomerKey = F.CustomerKey
    JOIN DateDim D ON F.DateKey = D.DateKey
    GROUP BY D.Year
)
SELECT 
    R.Year, 
    CASE 
        WHEN T.TotalCount = 0 THEN 0 -- Prevent division by zero
        ELSE (R.ReturningCount / T.TotalCount) 
    END AS CustomerRetention
FROM ReturningCustomers R
JOIN TotalCustomers T ON R.Year = T.Year
ORDER BY R.Year;

-- 2) Quarterly Total Number of Orders
SELECT 
    d.Year,
    d.Quarter,
    SUM(F.Orders) AS TotalNoOfOrders
FROM 
    FactOrders f
JOIN 
    DateDim d ON f.DateKey = d.DateKey
GROUP BY 
    d.Year, d.Quarter
ORDER BY 
    d.Year, d.Quarter;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-- Q2

 -- 4 Step Dimensional Model
 -- Step 1: Sales Performance
 -- Step 2: Order Status Fact Table
 -- Step 3: Date,Order, Customer
 -- Step 4: TimeSpentInStatus, Quantity

-- Create Dimension Tables
CREATE TABLE DimDate (
    DateKey int PRIMARY KEY,
	Date DATE,
    Year int,
    Quarter int,
    Month int,
    Day int
);

CREATE TABLE DimCustomer (
    CustomerKey int PRIMARY KEY,       
    CustomerID int,                     
    FirstName varchar(100),
	LastName varchar(100),
    Address varchar(100),
	City varchar(100),
    State varchar(100),
    ZipCode varchar(20),
    Phone varchar(100),
    Email varchar(100)                  
);

CREATE TABLE DimOrder(
	OrderKey int PRIMARY KEY,
	OrderID int
);

CREATE TABLE FactOrderStatus (
	OrderStatusKey int PRIMARY KEY,
	OrderKey int,
    CustomerKey int,
	Status varchar(100),      -- Ordered, Due, Shipped, Delivered
    Quantity int,
    OrderedDate DATE,
    DueDate DATE,
    ShippedDate DATE,
    DeliveredDate DATE,
    FOREIGN KEY (OrderKey) REFERENCES DimOrder(OrderKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey)
);

---------------------------------------------------------------------
-- 1) Calculate the time taken to move from Ordered to Due to Shipped to Delivered
SELECT
	OrderID,
	CustomerID,
    Quantity,
    DATEDIFF(day, OrderedDate, DueDate) AS DaysToDue,
    DATEDIFF(day, DueDate, ShippedDate) AS DaysToShipped,
    DATEDIFF(day, ShippedDate, DeliveredDate) AS DaysToDelivered
FROM DimCustomer c
JOIN 
    FactOrderStatus od ON od.CustomerKey=c.CustomerKey
JOIN 
	DimOrder o ON o.OrderKey=od.OrderKey;


-- 2) Calculate the total number of products that were ordered, due, and shipped
SELECT 
    'Ordered' AS Status,
    SUM(Quantity) AS TotalProducts
FROM FactOrderStatus
WHERE OrderedDate IS NOT NULL
UNION
SELECT 
    'Due' AS Status,
    SUM(Quantity) AS TotalProducts
FROM FactOrderStatus
WHERE DueDate IS NOT NULL
UNION
SELECT 
    'Shipped' AS Status,
    SUM(Quantity) AS TotalProducts
FROM FactOrderStatus
WHERE ShippedDate IS NOT NULL

