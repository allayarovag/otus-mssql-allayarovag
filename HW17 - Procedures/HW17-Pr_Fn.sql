--1�������� ������� ������������ ������� � ���������� ������ �������.
CREATE FUNCTION Sales.fn_MaxPriceCustomerID()
RETURNS INT
AS
BEGIN
	DECLARE @CustomerID INT

	SELECT 
	TOP 1 @CustomerID = a.CustomerID
	FROM 
		Sales.Invoices AS a
		JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	GROUP BY a.CustomerID
		,a.InvoiceID
	ORDER BY 
	sum(b.ExtendedPrice) desc

	RETURN @CustomerID
END
go

SELECT Sales.fn_MaxPriceCustomerID()

--2�������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
--������������ ������� :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

USE WideWorldImporters
GO
Create PROCEDURE [Sales].[Pr_ExtendedPriceCustomerID]
(
	@CustomerID int
)
as begin
	SELECT SUM(c.ExtendedPrice)
	FROM Sales.Customers	AS a
	JOIN Sales.Invoices		AS b ON a.CustomerID = b.CustomerID
	JOIN Sales.InvoiceLines AS c ON b.InvoiceID = c.InvoiceID
	WHERE
		a.CustomerID = @CustomerID
	GROUP BY a.CustomerID
end

EXEC [Sales].[Pr_ExtendedPriceCustomerID] @CustomerID = 5
GO
--3������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
USE WideWorldImporters
GO

Create or Alter PROCEDURE [Sales].[Pr_MaxPriceCustomerID]
as begin
	set nocount on

	SELECT 
	TOP 1 CustomerID = a.CustomerID
	FROM 
		Sales.Invoices AS a
		JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	GROUP BY a.CustomerID
		,a.InvoiceID
	ORDER BY 
	sum(b.ExtendedPrice) desc

end

set statistics IO off
set statistics time on

SELECT Sales.fn_MaxPriceCustomerID()
exec [Sales].[Pr_MaxPriceCustomerID]
GO

/*
� ��������� ����������� ���� �������.
����������� ���� �������, ����� ������.

� ���� ������ ��������� �������, �� � ������ ���������� 

������� 
 ����� ������ SQL Server:
   ����� �� = 62 ��, ����������� ����� = 73 ��.
����� ��������������� ������� � ���������� SQL Server: 
 ����� �� = 0 ��, �������� ����� = 0 ��.

���������

����� ������ SQL Server:
   ����� �� = 78 ��, ����������� ����� = 121 ��.

 ����� ������ SQL Server:
   ����� �� = 94 ��, ����������� ����� = 144 ��.
����� ��������������� ������� � ���������� SQL Server: 
 ����� �� = 0 ��, �������� ����� = 0 ��.

*/

--4�������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.
--�����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������.
Create or Alter FUNCTION Sales.fn_PriceCustomerID
(@CustomerID int)
RETURNS @PriceCustomerID TABLE(InvoiceID int, ExtendedPrice decimal(25,6))
AS
BEGIN
	insert into @PriceCustomerID (InvoiceID,ExtendedPrice)
	SELECT 
	a.InvoiceID, sum(b.ExtendedPrice)
	FROM 
		Sales.Invoices AS a
		JOIN Sales.InvoiceLines AS b ON a.InvoiceID = b.InvoiceID
	WHERE a.CustomerID = @CustomerID
	GROUP BY a.InvoiceID	
	RETURN
END
go

SELECT a.CustomerID, b.InvoiceID, b.ExtendedPrice
FROM Sales.Customers AS a
CROSS APPLY Sales.fn_PriceCustomerID(a.CustomerID) as b
