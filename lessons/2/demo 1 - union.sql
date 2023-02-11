USE WideWorldImporters;

-- ������� ������� � ����� �������
SELECT 'a' AS Col1
UNION
SELECT 'b' AS Col2
UNION
SELECT 'c' AS Col3;
GO

-- ������ ������� 
SELECT Col1
FROM (VALUES('a'), ('b'), ('c')) AS tbl (Col1);
GO

-- ����� �� ������� � ������������������ ����� ����� ����������?

-- ��������� �������
SELECT Col1, Col2
FROM (VALUES('a', 2), ('b', 4), ('c', 1)) AS tbl (Col1, Col2);
GO

-- ��� ������� UNION ��� UNION ALL?
SELECT 'a'
UNION ALL
SELECT 'a';

SELECT 'a'
UNION
SELECT 'a';
GO

-- ������������� �� ����� 
-- ������
SELECT 'a'
UNION 
SELECT 123;
GO

SELECT 'a'
UNION 
SELECT CAST(123 AS NCHAR(3));
GO