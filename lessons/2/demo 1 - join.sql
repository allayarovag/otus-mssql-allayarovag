/* tsqllint-disable error select-star */
USE WideWorldImporters;

-----------------------------------------
-- �������� �������
-----------------------------------------
DROP TABLE IF EXISTS dbo.Suppliers;
DROP TABLE IF EXISTS dbo.SupplierTransactions;

-- �������� ������� Suppliers
SELECT
  SupplierID,
  SupplierName
INTO dbo.Suppliers
FROM Purchasing.Suppliers
/* where - ����� � ������� ���� ������ ����� */
WHERE SupplierName IN ('A Datum Corporation', 'Contoso, Ltd.', 'Consolidated Messenger', 'Nod Publishers')
ORDER BY SupplierID;

-- �������� ������� -- SupplierTransactions
SELECT
  SupplierTransactionID,
  SupplierID,
  TransactionDate,
  TransactionAmount,
  TransactionTypeID
INTO dbo.SupplierTransactions
FROM Purchasing.SupplierTransactions
WHERE SupplierID IN (1, 2, 3, 9) /* ����� � ������� ���� ������ ����� */
ORDER BY SupplierID;

SELECT * FROM dbo.Suppliers;
SELECT * FROM dbo.SupplierTransactions;

-----------------------------------------
-- JOINS 
-----------------------------------------

-- CROSS JOIN ����� FROM, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s, dbo.SupplierTransactions t;

-- INNER JOIN ����� FROM � WHERE, ANSI SQL-89
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s, dbo.SupplierTransactions t
WHERE s.SupplierID = t.SupplierID -- <====== ������� ����������
ORDER BY s.SupplierID, t.SupplierID;

-- CROSS JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM Purchasing.Suppliers s
CROSS JOIN Purchasing.SupplierTransactions t
ORDER BY s.SupplierID, t.SupplierID;

-- ����� ������� ���������� ������ � JOIN
-- INNER JOIN, ANSI SQL-92
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
INNER JOIN dbo.SupplierTransactions t
	  ON t.SupplierID = s.SupplierID -- <====== ������� JOIN
ORDER BY s.SupplierID;

-- ��� ����������, ���� ���� � ��� ��� ����������
-- LEFT JOIN 
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
LEFT OUTER JOIN dbo.SupplierTransactions t
	ON t.SupplierID = s.SupplierID  -- <====== ������� JOIN
ORDER BY s.SupplierID;

-- RIGHT JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.SupplierTransactions t
RIGHT JOIN  dbo.Suppliers s
	ON s.SupplierID = t.SupplierID -- <====== ������� JOIN
ORDER BY s.SupplierID;

-- ����� ����������� LEFT JOIN ������ RIGHT JOIN - �������� �����

-- ����� ����������� (Supplier) ��� ���������� (transactions)
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.SupplierID,
  t.TransactionDate,
  t.TransactionAmount
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t
	ON t.SupplierID = s.SupplierID -- <====== ������� JOIN
WHERE t.SupplierTransactionID IS NULL
ORDER BY s.SupplierID;

---------------------------------------
-- ������� JOIN
---------------------------------------
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID;

-- �������� ������� Orders � Customers
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber,
	l.OrderLineID
FROM Sales.OrderLines l
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.Orders o ON o.OrderID = l.OrderID;

-- �������� ������� � FROM � JOIN
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID;

-- ������ ������� JOIN �� ������
-- �������������� �������:
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID;

-- ����� �� ������� � ������������������ ���� ��������?
-- ������� ����� ��������

-- �� �� ������� � FORCE JOIN - ��������� ������� ���������� JOIN
-- (������� �����)
SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
OPTION (FORCE ORDER);

SELECT TOP 10
    o.CustomerID,
    c.CustomerName,
    c.PhoneNumber
FROM Sales.Orders o
JOIN Sales.OrderLines l ON l.OrderID  = o.OrderID
JOIN Sales.Customers c ON c.CustomerID = o.CustomerID
OPTION (FORCE ORDER);
GO

--------------------------------
-- "�������� ������" LEFT JOIN
--------------------------------
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
ORDER BY s.SupplierID;

-- ������� TransactionTypes ����� INNER JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID,
  tt.TransactionTypeName
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
INNER JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;

-- ��� ������� ���, ����� ������ �� �������?











SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionAmount,
  t.TransactionTypeID,
  tt.TransactionTypeName
FROM dbo.Suppliers s
LEFT JOIN dbo.SupplierTransactions t ON t.SupplierID = s.SupplierID
LEFT JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;


-- � ����� ������, ��� ������� LEFT JOIN ��� INNER JOIN?