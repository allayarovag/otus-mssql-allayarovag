/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "03 - ����������, CTE, ��������� �������".
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
-- ��� ���� �������, ��� ��������, �������� ��� �������� ��������:
--  1) ����� ��������� ������
--  2) ����� WITH (��� ����������� ������)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. �������� ����������� (Application.People), ������� �������� ������������ (IsSalesPerson), 
� �� ������� �� ����� ������� 04 ���� 2015 ����. 
������� �� ���������� � ��� ������ ���. 
������� �������� � ������� Sales.Invoices.
*/

select PersonID, b.FullName from Application.People as b 
where IsSalesperson = 1
	and not exists (select * from sales.Invoices a where a.SalespersonPersonID = b.PersonID and a.InvoiceDate = '20150704')

/*
2. �������� ������ � ����������� ����� (�����������). �������� ��� �������� ����������. 
�������: �� ������, ������������ ������, ����.
*/

select StockItemID, StockItemName, UnitPrice from Warehouse.StockItems
where UnitPrice <= all(select UnitPrice from Warehouse.StockItems)

select StockItemID, StockItemName, UnitPrice from Warehouse.StockItems
where UnitPrice = (select min(UnitPrice) from Warehouse.StockItems)


/*
3. �������� ���������� �� ��������, ������� �������� �������� ���� ������������ �������� 
�� Sales.CustomerTransactions. 
����������� ��������� �������� (� ��� ����� � CTE). 
*/

select top 5 TransactionAmount,a.CustomerID,CustomerName 
from sales.CustomerTransactions as a 
join sales.Customers as b on b.CustomerID = a.CustomerID
order by 1 desc

/*
4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, 
�������� � ������ ����� ������� �������, � ����� ��� ����������, 
������� ����������� �������� ������� (PackedByPersonID).
*/

select
e.CityID,
e.CityName, 
d.FullName 
from Sales.Invoices as a
join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID 
join sales.Customers as c on c.CustomerID = a.CustomerID
join Application.Cities as e on e.CityID = c.DeliveryCityID
join Application.People as d on d.PersonID = a.PackedByPersonID
where b.StockItemID in (select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc)

-- ---------------------------------------------------------------------------
-- ������������ �������
-- ---------------------------------------------------------------------------
-- ����� ��������� ��� � ������� ��������� ������������� �������, 
-- ��� � � ������� ��������� �����\���������. 
-- �������� ������������������ �������� ����� ����� SET STATISTICS IO, TIME ON. 
-- ���� ������� � ������� ��������, �� ����������� �� (����� � ������� ����� ��������� �����). 
-- �������� ���� ����������� �� ������ �����������. 

-- 5. ���������, ��� ������ � ������������� ������
/*
������� �������. �� ������� ���� ��������� ������������ � ����� ����� ������ ������ 27000
��������:
	�������� ��������� id,
	����,
	��������,
	����� ����� ���������,
	����� ����� ������
*/
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
		(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = 
			(SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
;with a_Cte as (
	SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000)
,b_Cte as (
	select 
	a.InvoiceID,InvoiceDate,SalespersonPersonID,OrderID, b.TotalSumm
	from Sales.Invoices a
	join a_Cte b on a.InvoiceID = b.InvoiceID)

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	SalesPersonName			= People.FullName,
	TotalSummByInvoice		= Invoices.TotalSumm, 
	TotalSummForPickedItems = SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM 
	b_Cte as Invoices
	join Application.People as People on People.PersonID = Invoices.SalespersonPersonID
	join Sales.Orders as Orders on Orders.OrderId = Invoices.OrderId and Orders.PickingCompletedWhen IS NOT NULL
	join sales.OrderLines as OrderLines on OrderLines.OrderId = Orders.OrderId
	JOIN a_Cte AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
group by 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	People.FullName,
	Invoices.TotalSumm
ORDER BY 
	Invoices.TotalSumm DESC

--create nonclustered index [NCI_Orders_PickingCompletedWhen] on sales.orders (PickingCompletedWhen)

