/*
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
1. ��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
�������� ����� � ID 2-6, ��� ��� ������������� Tailspin Toys.
��� ������� ����� �������� ��� ����� �������� ������ ���������.
��������, �������� �������� "Tailspin Toys (Gasport, NY)" - �� �������� ������ "Gasport, NY".
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT| Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2       |     2
01.02.2013   |      7             |        3           |      4      |      2       |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
SELECT * 
	FROM (
	select
	[CustomerName] = SUBSTRING(b.CustomerName,
		CHARINDEX('(', b.CustomerName) + 1,
		CHARINDEX(')', b.CustomerName) - CHARINDEX('(', b.CustomerName) - 1)
	,a.OrderDate
	,a.OrderID
	from sales.Orders as a
	join sales.Customers as b on b.CustomerID = a.CustomerID
	where a.CustomerID between 2 and 6
	) AS Sales
PIVOT (count(OrderID) FOR [CustomerName] IN 
	([Gasport, NY],
	[Jessie, ND],
	[Medicine Lodge, KS],
	[Peeples Valley, AZ],
	[Sylvanite, MT]))
as PVT
order by OrderDate

/*
2. ��� ���� �������� � ������, � ������� ���� "Tailspin Toys"
������� ��� ������, ������� ���� � �������, � ����� �������.
������ ����������:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/
select CustomerName, Addresses from
	(select CustomerName, PostalAddressLine1, PostalAddressLine2, DeliveryAddressLine1, DeliveryAddressLine2
	from sales.Customers as a 
	where CustomerName like '%Tailspin Toys%') as a
	unpivot 
	([Addresses] for [AddressLine] in (PostalAddressLine1, PostalAddressLine2, DeliveryAddressLine1, DeliveryAddressLine2)) 
	as unpvt

/*
3. � ������� ����� (Application.Countries) ���� ���� � �������� ����� ������ � � ���������.
�������� ������� �� ������, �������� � �� ���� ���, 
����� � ���� � ����� ��� ���� �������� ���� ��������� ���.
������ ����������:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
select CountryID,unpvt.CountryName, unpvt.Code from 
	(select a.CountryID, a.CountryName, cast(a.IsoAlpha3Code as nvarchar(10)) as IsoAlpha3Code
	,cast(a.IsoNumericCode as nvarchar(10)) as IsoNumericCode
	from Application.Countries as a) as sss
unpivot 
	(Code for codeType in ([IsoAlpha3Code], [IsoNumericCode])) 
	as unpvt


/*
4. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/

;with a as (
select a.CustomerID, b.StockItemID from Sales.Customers as a 
cross apply (
	select top 2 
	a.CustomerID, StockItemID, UnitPrice from sales.Orders as a 
	join sales.OrderLines as b on b.OrderID = a.OrderID
	where a.CustomerID = a.CustomerID
	group by a.CustomerID, StockItemID, UnitPrice
	order by UnitPrice desc) as b
	)
select 
o.CustomerID, c.CustomerName, b.StockItemID, UnitPrice, o.OrderDate
from sales.Orders as o
join sales.OrderLines as b on b.OrderID = o.OrderID
join sales.Customers as c on c.CustomerID = o.CustomerID
join a as a on a.CustomerID = o.CustomerID and a.StockItemID = b.StockItemID
order by o.CustomerID, o.OrderDate


/*
USE [WideWorldImporters]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter FUNCTION [Sales].[MaxPrice](@CustomerID int)
RETURNS TABLE
AS
RETURN (
	select top 2 
	a.CustomerID, StockItemID, UnitPrice from sales.Orders as a 
	join sales.OrderLines as b on b.OrderID = a.OrderID
	where a.CustomerID = @CustomerID
	group by a.CustomerID, StockItemID, UnitPrice
	order by UnitPrice desc
	);
GO
*/

;with a as (
select a.CustomerID, b.StockItemID from Sales.Customers as a 
cross apply [Sales].[MaxPrice](a.CustomerID) as b
)
select 
o.CustomerID, c.CustomerName, b.StockItemID, UnitPrice, o.OrderDate
from sales.Orders as o
join sales.OrderLines as b on b.OrderID = o.OrderID
join sales.Customers as c on c.CustomerID = o.CustomerID
join a as a on a.CustomerID = o.CustomerID and a.StockItemID = b.StockItemID
order by o.CustomerID, o.OrderDate