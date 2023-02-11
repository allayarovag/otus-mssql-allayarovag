/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.
������� "02 - �������� SELECT � ������� �������, JOIN".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� WideWorldImporters ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
1. ��� ������, � �������� ������� ���� "urgent" ��� �������� ���������� � "Animal".

�������: �� ������ (StockItemID), ������������ ������ (StockItemName).
�������: Warehouse.StockItems.
*/

-- �������� ����� ���� �������

/*
2. ����������� (Suppliers), � ������� �� ���� ������� �� ������ ������ (PurchaseOrders).
������� ����� JOIN, � ����������� ������� ������� �� �����.

�������: �� ���������� (SupplierID), ������������ ���������� (SupplierName).
�������: Purchasing.Suppliers, Purchasing.PurchaseOrders.
�� ����� �������� ������ JOIN ��������� ��������������.
*/

-- �������� ����� ���� �������

/*
3. ������ (Orders) � �������� ����� (UnitPrice) ����� 100$
���� ����������� ������ (Quantity) ������ ����� 20 ����
� �������������� ����� ������������ ����� ������ (PickingCompletedWhen).

�������:
* OrderID
* ���� ������ (OrderDate) � ������� ��.��.���� (10.01.2011)
* �������� ������, � ������� ��� ������ ����� (����������� ������� FORMAT ��� DATENAME)
* ����� ��������, � ������� ��� ������ ����� (����������� ������� DATEPART)
* ����� ����, � ������� ��������� ���� ������ (������ ����� �� 4 ������)
* ��� ��������� (Customer)
�������� ������� ����� ������� � ������������ ��������,
��������� ������ 1000 � ��������� ��������� 100 �������.

���������� ������ ���� �� ������ ��������, ����� ����, ���� ������ (����� �� �����������).

�������: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- �������� ����� ���� �������

/*
4. ������ ����������� (Purchasing.Suppliers),
������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ����
� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName)
� ������� ��������� (IsOrderFinalized).

�������:
* ������ �������� (DeliveryMethodName)
* ���� �������� (ExpectedDeliveryDate)
* ��� ����������
* ��� ����������� ���� ������������ ����� (ContactPerson)

�������: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

-- �������� ����� ���� �������

/*
5. ������ ��������� ������ (�� ���� ������� - InvoiceDate) � ������ ������� (������ - CustomerID) � ������ ����������,
������� ������� ����� (SalespersonPerson).
������� ��� �����������.

�������: �� ������� (InvoiceID), ���� ������� (InvoiceDate), ��� ��������� (CustomerName), ��� ���������� (SalespersonFullName)
�������: Sales.Invoices, Sales.Customers, Application.People.
*/

-- �������� ����� ���� �������

/*
6. ��� �� � ����� �������� (������ - CustomerID) � �� ���������� �������� (PhoneNumber),
������� �������� ����� "Chocolate frogs 250g".
��� ������ �������� � ������� Warehouse.StockItems, ����� �������� � �� �������� � ������� Sales.Customers.

�������: Sales.Invoices, Sales.InvoiceLines, Sales.Customers, Warehouse.StockItems.
*/

-- �������� ����� ���� �������