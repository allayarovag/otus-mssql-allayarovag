/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "06 - ������� �������".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
��������: id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������

������:
-------------+----------------------------
���� ������� | ����������� ���� �� ������
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
*/
;with a as (
	select c.CustomerID,a.InvoiceDate,  c.CustomerName, sum(b.ExtendedPrice) as ExtendedPrice
	from sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join sales.Customers as c on c.CustomerID = a.CustomerID
	where a.InvoiceDate >= '20150101'
	group by  c.CustomerID,a.InvoiceDate,  c.CustomerName, a.InvoiceDate
)

select 
	a.InvoiceDate
	,a.CustomerName
	,a.ExtendedPrice
	,(select sum(bb.ExtendedPrice) from Sales.Invoices as aa 
	join sales.InvoiceLines as bb on bb.InvoiceID = aa.InvoiceID
	where month(aa.InvoiceDate) <= month(a.InvoiceDate)
	and aa.InvoiceDate >= '20150101')
from a as a 
order by a.InvoiceDate,a.CustomerName

/*
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
   �������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/
/*�������� ����� ���� �������*/

;with a as (
	select a.InvoiceDate,  c.CustomerName, sum(b.ExtendedPrice) as ExtendedPrice
	from sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join sales.Customers as c on c.CustomerID = a.CustomerID
	where a.InvoiceDate >= '20150101'
	group by  a.InvoiceDate,  c.CustomerName, a.InvoiceDate)
select 
* 
,sum(a.ExtendedPrice) over (order by month(a.InvoiceDate))
from a as a 
order by a.InvoiceDate, a.CustomerName

--������� � �������� ��������� ������������ � ���� �������, ������ ������

/*
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
*/
;with a as (
	select 
	month(a.InvoiceDate) as mm, 
	b.StockItemID, 
	count(*) as counts 
	from sales.Invoices as a
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	where YEAR(a.InvoiceDate) = '2016'
	group by month(a.InvoiceDate), b.StockItemID) 

select 
mm, si.StockItemName, RN
from (
	select 
	*, ROW_NUMBER() over (partition by mm order by counts desc) as RN
	from a as a
) as result
join Warehouse.StockItems as si on si.StockItemID = result.StockItemID
where RN <=2
order by mm, RN
/*
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
* ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
* ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
* ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
* ���������� �� ������ � ��� �� �������� ����������� (�� �����)
* �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
* ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��

��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
*/

select 
	StockItemID,
	StockItemName,
	Brand,
	UnitPrice,
	left(StockItemName,1),
	ROW_NUMBER() over (partition by left(StockItemName,1) order by StockItemName),
	count(*) over (),
	count(*) over (partition by left(StockItemName,1)),
	lead(StockItemID) over (order by StockItemName),
	lag(StockItemID) over (order by StockItemName),
	lag(StockItemName,2,'No items') over (order by StockItemName),
	ntile(30) over (order by TypicalWeightPerUnit)
from 
Warehouse.StockItems
order by 2
/*
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
   � ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/
;with cte as (
select 
a.InvoiceID, a.SalespersonPersonID ,a.InvoiceDate,
ROW_NUMBER() over (partition by a.SalespersonPersonID order by a.InvoiceID desc) as rn
from Sales.Invoices as a 
)

select 
a.SalespersonPersonID, 
b.FullName,
a.CustomerID,
c.CustomerName,
a.InvoiceDate,
il.ExtendedPrice
from Sales.Invoices as a 
join (select sum(ExtendedPrice) as ExtendedPrice, InvoiceID from Sales.InvoiceLines as il group by InvoiceID) as il on il.InvoiceID = a.InvoiceID
join cte as cte on cte.InvoiceID = a.InvoiceID and rn = 1
join Application.People as b on b.PersonID = a.SalespersonPersonID
join sales.Customers as c on c.CustomerID = a.CustomerID
order by 2,5


/*
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

;with cte_a as (
select distinct 
	a.CustomerID,
	d.CustomerName,
	b.StockItemID,
	c.UnitPrice
from 
	sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join Warehouse.StockItems as c on c.StockItemID = b.StockItemID
	join sales.Customers as d on d.CustomerID =a.CustomerID)
,cte_top2 as (
select *, ROW_NUMBER() over (partition by CustomerID order by UnitPrice desc) as rn
from cte_a
)

select 
c.CustomerID,
c.CustomerName,
c.StockItemID,
c.UnitPrice,
a.InvoiceDate
from 
sales.Invoices as a 
join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
join cte_top2 as c on c.CustomerID = a.CustomerID and c.StockItemID = b.StockItemID and c.rn <=2


--����������� ������ ��� ������� ������� ��� ������� ������� ������� ������� �������� � �������� ��������� � �������� �� ������������������. 