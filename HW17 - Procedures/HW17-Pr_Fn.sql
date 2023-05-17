--1Написать функцию возвращающую Клиента с наибольшей суммой покупки.
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

--2Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
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
--3Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
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
У процедуры полноценный план запроса.
Отсутствует план запроса, одним блоком.

В моем случае процедура тяжелее, но в случае увеличения 

функция 
 Время работы SQL Server:
   Время ЦП = 62 мс, затраченное время = 73 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

Процедура

Время работы SQL Server:
   Время ЦП = 78 мс, затраченное время = 121 мс.

 Время работы SQL Server:
   Время ЦП = 94 мс, затраченное время = 144 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

*/

--4Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
--Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему.
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
