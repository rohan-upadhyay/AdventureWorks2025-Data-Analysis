-- List all products from Production.Product. 

select distinct englishproductname from dimproduct

-- Show Name, Color, and ListPrice for all products.

select englishproductname, color, listprice from dimproduct

-- Find products with a ListPrice greater than 1000.

select englishproductname, listprice from dimproduct
where listprice >1000

-- Find all products where Color is Red. 

select englishproductname, color from dimproduct
where color = 'Red'

-- Sort products by ListPrice from highest to lowest. 

select englishproductname, listprice from dimproduct
order by listprice desc

-- Find the top 10 most expensive products

select top 10 englishproductname, listprice from dimproduct
order by listprice desc

-- Count how many products exist in each ProductSubcategory.

select ds.EnglishProductSubcategoryName, count(ds.productsubcategorykey) 
as product_count
from dimproduct as dp
join DimProductSubcategory as ds
on dp.productsubcategorykey = ds.productsubcategorykey
group by ds.EnglishProductSubcategoryName
order by count(ds.productsubcategorykey) desc


-- Find the average ListPrice for each product category.

SELECT ds.EnglishProductSubcategoryName, AVG(dp.ListPrice)
AS AVG_ListPrice
FROM DimProduct AS dp
JOIN DimProductSubcategory AS ds
ON dp.ProductSubcategoryKey = ds.ProductSubcategoryKey
GROUP BY ds.EnglishProductSubcategoryName
ORDER BY AVG_ListPrice DESC

-- Show customers who have placed more than 5 orders.

select cs.customerkey, concat_ws(' ', cs.FirstName,cs.middlename,cs.lastname) as CustName,
count(ft.orderquantity) as Morethan5
from DimCustomer as CS
Join FactInternetSales as FT
on cs.CustomerKey = ft.CustomerKey
group by cs.customerkey,concat_ws(' ', cs.FirstName,cs.middlename,cs.lastname)
having count(ft.orderquantity) > 5
order by morethan5 asc

-- Find the total sales amount for each customer.

select cs.customerkey, sum(ft.salesamount) as TotalSales
from DimCustomer as CS
Join FactInternetSales as FT
on cs.CustomerKey = ft.CustomerKey
group by cs.customerkey
Order By Totalsales desc


-- Display product names along with their product subcategory names.

select dp.ProductSubcategorykey, dp.EnglishProductName, dc.EnglishProductSubcategoryName
from dimproduct as dp
join dimproductsubcategory as Dc
on dp.ProductSubcategoryKey = dc.productsubcategorykey
order by dp.ProductSubCategoryKey asc

-- Display customer names and their sales order numbers.

select concat_ws(' ', dc.FirstName, dc.MiddleName, dc.LastName) as Cust_Name, fs.SalesorderNumber
from Dimcustomer as Dc
join factinternetsales as FS
on dc.CustomerKey = fs.CustomerKey

-- Find the top 10 customers by total sales.

select Top 10 dc.customerkey, concat_ws(' ', dc.FirstName, dc.MiddleName, dc.LastName) as Cust_Name,
sum(fs.SalesAmount) as Total_Sales
from DimCustomer as DC
join FactInternetSales as FS
on dc.CustomerKey = fs.CustomerKey 
group by dc.customerkey, concat_ws(' ', dc.FirstName, dc.MiddleName, dc.LastName)
order by total_sales desc

-- Find products that have never been ordered.

select dp.Productkey, dp.EnglishProductName, fs.Salesamount as TotalSales from Dimproduct as DP
Left join FactInternetSales as FS
on dp.ProductKey = fs.ProductKey
where fs.Productkey is Null

-- Find the 3rd highest product price.
--Dynamic - just change the Ranks No to get the desired output
with cte_3rdhigh
as
( select salesamount,
dense_rank()
over ( order by salesamount desc) as Ranks
from factinternetsales ) 
Select salesamount from cte_3rdhigh
where Ranks = 3

-- Rank products by price within each product category.

with cte_all
as
(select p.productkey, p.englishproductname,
pc.englishproductcategoryname, p.listprice,
rank() 
over( partition by pc.EnglishProductCategoryName order by listprice desc) as PRanks
from dimproduct as p
join DimProductSubcategory as psc
on p.ProductSubcategoryKey = psc.ProductSubcategoryKey
join DimProductCategory as pc
on psc.ProductCategoryKey = pc.ProductCategoryKey
where p.ListPrice > 0)
select * from cte_all

-- Find the employee with the highest total sales.

select top 1 fe.employeekey, CONCAT_WS(' ', de.firstname, de.middlename, de.lastname) as Emp_Name,
sum(fe.salesamount) as highest_sale from DimEmployee as de
join FactResellerSales as FE
on de.employeekey = fe.EmployeeKey
group by fe.employeekey, CONCAT_WS(' ', de.firstname, de.middlename, de.lastname)
order by sum(fe.salesamount) desc

-- Calculate monthly sales totals.

with cte_monthly
as

( select month(orderdate) as MO_Num,
(format(orderdate,'MMM')) as MO_name,
year(orderdate) as Yr,
sum(salesamount) as Total_sales
from factinternetsales
group by month(orderdate),(format(orderdate,'MMM')),
year(orderdate))
select mo_num, MO_name, Yr, Total_sales from cte_monthly
order by Yr, mo_num

-- Find customers whose total spending is above the average customer spending.

with c_spend
as
(
select customerkey,
sum(salesamount) as total_spending
from FactInternetSales
group  by customerkey)

 select customerkey, total_spending
 from c_spend
 where total_spending >

(
select avg(total_spending)
from c_spend 
)
order by total_spending desc





