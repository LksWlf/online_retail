-- create table
drop table if exists projects.online_retail
;

use `projects`;
create table online_retail (
Invoice varchar(50),
StockCode varchar(50),
Description varchar(50),
Quantity int,
InvoiceDate datetime,
Price double,
CustomerID int,
Country varchar(50)
);

-- load data from file into table
SET GLOBAL local_infile=1;
use `projects`;
LOAD DATA LOCAL INFILE  
'C:/Users/Lukas Wolf/Documents/projects/rfm-online_retail/online_retail.csv'
INTO TABLE online_retail
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- first view at data
select *
from projects.online_retail
limit 100
;

-- checking for duplicated rows
-- dist_row = 1 will be non-duplicated, all other values for dist_row will be duplicates
with dup_rows as (
select 
	row_number() over(partition by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID) as dist_row
	, Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
from projects.online_retail
)
select 
	count(*)
	, dist_row
from dup_rows 
group by 2
;

-- checking for missing values / blanks
select 
	count(*)
    , sum(case when nullif(Invoice,'') is null then 0 else 1 end)
    , sum(case when nullif(StockCode,'') is null then 0 else 1 end)
	, sum(case when nullif(Description,'') is null then 0 else 1 end)
	, sum(case when nullif(Quantity,'') is null then 0 else 1 end)
	, sum(case when InvoiceDate is null then 0 else 1 end)
	, sum(case when nullif(Price,'') is null then 0 else 1 end)
	, sum(case when nullif(CustomerID,'') is null then 0 else 1 end)
from projects.online_retail
;

-- we have some missing values for Description, Price and CustomerID
with dup_rows as (
select 
	row_number() over(partition by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID) as dist_row
	, Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
from projects.online_retail
)
select 
	count(*)
    , sum(case when Price = 0 then 1 else 0 end)
    , case when CustomerID = 0 then 0 else 1 end
from dup_rows 
where dist_row = 1
group by 3
;

-- how could we fill up the missing CustomerIDs? idea: if we are lucky, the CustomerID is filled for other entries of that specific invoice
-- testing, but not working:
select count(distinct CustomerID) num_cst_id
, Invoice 
from projects.online_retail 
group by 2 
having count(distinct CustomerID) > 1;
/*
So we need to drop those entries with missing CustomerID
Decided to drop remaining rows with: Price = 0
There exist just very few entries, where Price = 0 and CustomerID <> 0
It's not possible to certainly define a Price value in these cases, as Prices could differ dependent on season or maybe customers.
There are several different prices per Description / Product Categorie in some cases
*/

-- Checking manually for some pricing outliers, most of them seem to be entries added manually. In a real world scenario, this would need to be challenged.
select *
from projects.online_retail
order by Price asc
limit 100
;

-- Checking manually if date outliers exists, but does look fine
select count(*)
, extract(YEAR_MONTH from InvoiceDate)
from projects.online_retail
group by extract(YEAR_MONTH from InvoiceDate)
order by extract(YEAR_MONTH from InvoiceDate)
limit 100
;

with dup_rows as (
select 
	row_number() over(partition by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID) as dist_row
	, Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
from projects.online_retail
)
, fct_invoices as (
select 
	Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
    , Price * Quantity as total_price
	, sum(Price * Quantity) over(partition by Invoice) as Invoice_price
from dup_rows
where 1 = 1  
    and Price > 0
    and CustomerID > 0 
    and dist_row = 1
)
, cst_inv as (
select 
	count(distinct Invoice) as num_inv
    , datediff(date'2012-01-01',max(InvoiceDate)) as last_inv -- date 01-01-2012 fits to data
    , sum(total_price) as sum_price
	, CustomerID
from fct_invoices
group by CustomerID
)
, cst_kpi as (
select 
	CustomerID
     -- group 4 being best, group 1 lowest performing group of customers
    , ntile(4) over(order by last_inv desc) as rec_group
    , last_inv
    , ntile(4) over(order by num_inv asc) as freq_group
    , num_inv
    , ntile(4) over(order by sum_price asc) as mon_group
    , sum_price
    , ntile(4) over(order by last_inv desc) + ntile(4) over(order by num_inv asc) + ntile(4) over(order by sum_price asc) as rfm_score
from cst_inv 
)
select 
	count(distinct CustomerID)
	, rec_group
    , round(avg(last_inv),1)
    , freq_group
    , round(avg(num_inv),1)
    , mon_group
    , round(avg(sum_price),1)
    , rfm_score
from cst_kpi
group by 2,4,6,8
order by rfm_score
;

-- as an alternative, companies sometimes tend to define segments based on receny and frequency only, which leads to easier 2D visualizations and an easier understanding of the different segments

with dup_rows as (
select 
	row_number() over(partition by Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID) as dist_row
	, Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
from projects.online_retail
)
, fct_invoices as (
select 
	Invoice
    , StockCode
    , Description
    , Quantity
    , InvoiceDate
    , Price
    , CustomerID
    , Price * Quantity as total_price
	, sum(Price * Quantity) over(partition by Invoice) as Invoice_price
from dup_rows
where 1 = 1  
    and Price > 0
    and CustomerID > 0 
    and dist_row = 1
)
, cst_inv as (
select 
	count(distinct Invoice) as num_inv
    , datediff(date'2012-01-01',max(InvoiceDate)) as last_inv -- date 01-01-2012 fits to data
	, CustomerID
from fct_invoices
group by CustomerID
)
, cst_kpi as (
select 
	CustomerID
     -- group 5 being best, group 1 lowest performing group of customers
    , ntile(5) over(order by last_inv desc) as rec_group
    , last_inv
    , ntile(5) over(order by num_inv asc) as freq_group
    , num_inv
from cst_inv 
)
, cst_seg as (
Select 
	CustomerID
    , last_inv
    , num_inv
    , case 
		when rec_group between 1 and 2 and freq_group between 1 and 2 then 'hibernating'
        when rec_group between 1 and 2 and freq_group between 3 and 4 then 'at_risk'
        when rec_group between 1 and 2 and freq_group = 5 then 'cant_loose'
        when rec_group = 3 and freq_group between 1 and 2 then 'about_to_sleep'
        when rec_group = 3 and freq_group = 3 then 'need_attention'
		when rec_group between 3 and 4 and freq_group between 4 and 5 then 'loyal_customers'
        when rec_group = 4 and freq_group = 1 then 'promising'
        when rec_group = 5 and freq_group = 1 then 'new_customers'
        when rec_group between 4 and 5 and freq_group between 2 and 3 then 'potential_loyalists'
        when rec_group = 5 and freq_group between 4 and 5 then 'champions'
        else null 
        end as cust_segment
from cst_kpi
)
select 
	count(distinct CustomerID)
    , avg(last_inv)
    , avg(num_inv)
    , cust_segment
from cst_seg
group by 
	cust_segment
;
