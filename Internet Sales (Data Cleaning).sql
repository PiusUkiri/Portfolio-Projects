--Power BI Portfolio Project
--Prompt:
----Hi Pius!

--I hope you are doing well. We need to improve our internet sales reports and want to move from static reports to visual dashboards.

--Essentially, we want to focus it on how much we have sold of what products, to which clients and how it has been over time.

--Seeing as each sales person works on different products and customers it would be beneficial to be able to filter them also.

--We measure our numbers against budget so I added that in a spreadsheet so we can compare our values against performance.

--The budget is for 2021 and we usually look 2 years back in time when we do analysis of sales.

--Let me know if you need anything else!

--Steven - Sales Manager
--NOTE: All data will be gotten from AdventureWorksDW2019


--Solution: 
--First let's clean DIM_Date Table --
SELECT 
  [DateKey], 
  [FullDateAlternateKey] AS Date,  
  [EnglishDayNameOfWeek] AS Day, 
  [EnglishMonthName] AS Month, 
  Left([EnglishMonthName], 3) AS MonthShort,   -- Useful for front end date navigation and front end graphs.
  [MonthNumberOfYear] AS MonthNo, 
  [CalendarQuarter] AS Quarter, 
  [CalendarYear] AS Year 
FROM 
 [AdventureWorksDW2019].[dbo].[DimDate]
WHERE 
  CalendarYear >= 2019

--Now let's clean DIM_Customers Table --
SELECT 
  c.customerkey	AS CustomerKey, 
  c.firstname	AS [First Name], 
  c.lastname	AS [Last Name], 
  c.firstname + ' ' + lastname AS [Full Name], -- Combined First and Last Name
  CASE c.gender WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' END AS Gender,
  c.datefirstpurchase AS DateFirstPurchase, 
  g.city AS [Customer City] -- Joined in Customer City from Geography Table
FROM 
  [AdventureWorksDW2019].[dbo].[DimCustomer] as c
  LEFT JOIN dbo.dimgeography AS g ON g.geographykey = c.geographykey 
ORDER BY 
  CustomerKey ASC -- Ordered List by 

--Next let's clean DIM_Products Table --
SELECT 
  p.[ProductKey], 
  p.[ProductAlternateKey] AS ProductItemCode, 
  p.[EnglishProductName] AS [Product Name], 
  ps.EnglishProductSubcategoryName AS [Sub Category], -- Joined in from Sub Category Table
  pc.EnglishProductCategoryName AS [Product Category], -- Joined in from Category Table
  p.[Color] AS [Product Color], 
  p.[Size] AS [Product Size], 
  p.[ProductLine] AS [Product Line], 
  p.[ModelName] AS [Product Model Name], 
  p.[EnglishDescription] AS [Product Description], 
  ISNULL (p.Status, 'Outdated') AS [Product Status] 
FROM 
  [AdventureWorksDW2019].[dbo].[DimProduct] as p
  LEFT JOIN dbo.DimProductSubcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey 
  LEFT JOIN dbo.DimProductCategory AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey 
order by 
  p.ProductKey asc

--Lastly, let's clean the FACT_InternetSales Table --
SELECT 
  [ProductKey], 
  [OrderDateKey], 
  [DueDateKey], 
  [ShipDateKey], 
  [CustomerKey], 
  [SalesOrderNumber], 
  [SalesAmount]
FROM 
  [AdventureWorksDW2019].[dbo].[FactInternetSales]
WHERE 
  LEFT (OrderDateKey, 4) >= YEAR(GETDATE()) -3 -- Ensures we always only bring two years of date from extraction.
ORDER BY
  OrderDateKey ASC