USE WideWorldImporters;

-- ����� � WHERE
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE (Quantity * UnitPrice) /*[TotalCost]*/ > 1000;

-- ����� � ORDER BY
SELECT OrderLineID AS [Order Line ID],
       Quantity,
       UnitPrice,
       (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
ORDER BY [TotalCost];

-- ������� ���������� SELECT: 
--  FROM
--  WHERE
--  GROUP BY
--  HAVING
--  SELECT
--  ORDER BY