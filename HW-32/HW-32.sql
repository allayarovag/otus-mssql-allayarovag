--set statistics io,time on
--!!!!����!!!!
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.

-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 62 ��, �������� ����� = 83 ��.

--(3619 rows affected)
--������� "StockItemTransactions". ������������ 1, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 66, ���������� �������� ������ LOB 1, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 130, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
--������� "OrderLines". ������������ 4, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 518, ���������� �������� ������ LOB 5, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 795, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "OrderLines". ������� ��������� 2, ��������� 0.
--������� "Worktable". ������������ 0, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "CustomerTransactions". ������������ 5, ���������� �������� ������ 261, ���������� �������� ������ 4, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 253, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "Orders". ������������ 2, ���������� �������� ������ 883, ���������� �������� ������ 4, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 849, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "Invoices". ������������ 1, ���������� �������� ������ 70612, ���������� �������� ������ 2, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 11630, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "StockItems". ������������ 1, ���������� �������� ������ 2, ���������� �������� ������ 1, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.

--(1 row affected)

-- ����� ������ SQL Server:
--   ����� �� = 391 ��, ����������� ����� = 5985 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.

-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.

--Completion time: 2023-06-21T13:59:11.3549147+05:00

--Completion time: 2023-07-05T11:54:29.5982342+05:00
Select
	ord.CustomerID, 
	det.StockItemID, 
	SUM(det.UnitPrice),
	SUM(det.Quantity), 
	COUNT(ord.OrderID)
FROM 
	Sales.Orders AS ord
	JOIN Sales.OrderLines AS det							ON det.OrderID = ord.OrderID
	JOIN Sales.Invoices AS Inv								ON Inv.OrderID = ord.OrderID
	JOIN Sales.CustomerTransactions AS Trans				ON Trans.InvoiceID = Inv.InvoiceID
	inner JOIN Warehouse.StockItemTransactions AS ItemTrans	ON ItemTrans.StockItemID = det.StockItemID
WHERE 
	Inv.BillToCustomerID != ord.CustomerID
	AND (Select SupplierId
		FROM Warehouse.StockItems AS It
		Where It.StockItemID = det.StockItemID) = 12
	AND (
		SELECT SUM(Total.UnitPrice*Total.Quantity)
		FROM Sales.OrderLines AS Total
		Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID
		WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
	AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

/*
1. �������� ����������, ��������� ���������� ������. �������  ����� ������� ������
2. ������� ���� �������. ��������� ��������� "������" ���������� �������. �������� �� ���� ����������.
2. ��������� ���� ������������, �������(�������), ����������. ��������� ������� ��������.
3. ���� ������ ������ �� ������ ����, ������������� ���� �� �������� ������ ����. ����� ��������� ������� �����.
4. ���������/��������� ����������, ���� �������. ������������ � ������ 1 � �.�.

�������/ ��������� �������, �������� ������ ���������� ������,����� �� � ���������� �����.
*/

--!!!�����!!!
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.

-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 36 ��, �������� ����� = 36 ��.

--(3619 rows affected)
--������� "StockItemTransactions". ������������ 1, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 29, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "StockItemTransactions". ������� ��������� 1, ��������� 0.
--������� "OrderLines". ������������ 4, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 331, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "OrderLines". ������� ��������� 2, ��������� 0.
--������� "Worktable". ������������ 0, ���������� �������� ������ 0, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "CustomerTransactions". ������������ 5, ���������� �������� ������ 261, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "Orders". ������������ 2, ���������� �������� ������ 320, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "Invoices". ������������ 1, ���������� �������� ������ 226, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.
--������� "StockItems". ������������ 1, ���������� �������� ������ 2, ���������� �������� ������ 0, �������� ������ ����������� ������� 0, �������� ������, ����������� � ����������� 0, �������� ������ ����������� �������, ����������� � ����������� 0, ���������� �������� ������ LOB 0, ���������� �������� ������ LOB 0, �������� ������ LOB ����������� ������� 0, �������� ������ LOB, ����������� � ����������� 0, �������� ������ LOB ����������� �������, ����������� � ����������� 0.

--(1 row affected)

-- ����� ������ SQL Server:
--   ����� �� = 219 ��, ����������� ����� = 310 ��.
--����� ��������������� ������� � ���������� SQL Server: 
-- ����� �� = 0 ��, �������� ����� = 0 ��.

-- ����� ������ SQL Server:
--   ����� �� = 0 ��, ����������� ����� = 0 ��.

--Completion time: 2023-07-05T13:09:10.6118999+05:00



--�� �������, ���������  ������, ������� �����.
--DROP INDEX [FK_Sales_Orders_CustomerID] ON [Sales].[Orders]
--GO

--CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID_OrderDate] ON [Sales].[Orders]
--(
--	[CustomerID] ASC
--)
--INCLUDE([OrderDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
--GO

--CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_StockItemID] ON [Sales].[OrderLines]
--(
--	[StockItemID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
--GO


--���������, �� �������...������� �����.
--DROP INDEX [FK_Sales_Invoices_OrderID] ON [Sales].[Invoices]
--GO

--DROP INDEX [FK_Sales_Invoices_OrderID_InvoiceDate] ON [Sales].[Invoices]
--GO



--CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_OrderID_InvoiceDate_CustomerID] ON [Sales].[Invoices]
--(
--	[OrderID] ASC
--) INCLUDE([CustomerID], [InvoiceDate],[BillToCustomerID])
--GO

--CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_InvoiceDate] ON [Sales].[Invoices]
--(
--	[InvoiceDate] ASC
--)
--INCLUDE([OrderID],[BillToCustomerID]) 
--GO

/****** Object:  Index [FK_Sales_CustomerTransactions_InvoiceID]    Script Date: 05.07.2023 13:04:34 ******/
--CREATE NONCLUSTERED INDEX [FK_Sales_CustomerTransactions_InvoiceID_StockItemID] ON [Sales].[CustomerTransactions]
--(
--	[InvoiceID] ASC
--)INCLUDE(StockItemID) 



--DROP INDEX [FK_Sales_Orders_CustomerID_OrderDate] ON [Sales].[Orders]
--GO

--/****** Object:  Index [FK_Sales_Orders_CustomerID_OrderDate]    Script Date: 05.07.2023 13:34:36 ******/
--CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID_OrderDate_OrderID] ON [Sales].[Orders]
--(
--	[OrderID] ASC
--)
--INCLUDE([CustomerID], [OrderDate]) 
--GO
