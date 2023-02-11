/* tsqllint-disable error select-star */

USE WideWorldImporters;

-- ������ ���������
SELECT 1, N'�����-�� �����', 10 * 123, 'abc' + 'def';

-- ��������� ����� �� ������������
-- ������ ������ � ����� � ������������� ������
-- (� ���������� ����� ���������, ���� ��� �� ������� ��� ������� �����-�� �������)
SELECT *
FROM Application.Cities;
-- Application.Cities - ���������� �������

-- ����� �������� ������ ������ ����
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities;

-- ������ (����������) �������
SELECT 
    CityID,
    CityName AS City,
    CityName City2,
    CityName AS [City Name],
    CityName AS "City Name Again",
    City3 = CityName,
    c.StateProvinceID
FROM Application.Cities AS c;

-- � ��� ����� ��������? 
-- ��� ����� ���������?
SELECT
    CityID,
    CityName AS City,
    CityName City,
    CityName AS City,
    City3 = CityName,
    c.StateProvinceID
FROM Application.Cities AS c;

-- -------------------------------
--  ORDER BY - ����������
-- -------------------------------
-- �� ���������, ��� ��� ORDER BY ������� ���

-- ORDER BY
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities
ORDER BY CityName; -- ASC

-- ORDER BY (��������� �������), ASC / DESC
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities c
ORDER BY c.StateProvinceID ASC, c.CityName DESC;

-- � ��� ��� �����? ORDER BY 1, 2, 3
-- ����������� ������?
SELECT CityID, CityName, StateProvinceID
FROM Application.Cities c
ORDER BY 1, 2, 3;

-- -------------------------------
--  DISTINCT - �������� ������
-- -------------------------------

SELECT 
    CityName AS City
FROM Application.Cities;

SELECT DISTINCT 
    CityName AS City
FROM Application.Cities;
GO

-- ��������� ������� => ���������� ������
SELECT DISTINCT 
    CityName AS City,
    CityID,
    StateProvinceID
FROM Application.Cities;

-- -------------------------------
-- TOP - ������ N �������
-- -------------------------------
-- �� ������ �������� (c���������) ������ ������� ������ 10 �������?
SET STATISTICS TIME ON;

SELECT TOP 10
    CityID,
    CityName AS City,
    CityName City2,
    City3 = CityName,
    StateProvinceID
FROM Application.Cities;

-- � �����?
SELECT TOP 10 
    CityID,
    CityName AS City, 
    CityName City2,
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;

SET STATISTICS TIME OFF;

-- � ����� �� �������� �������?
-- � ���������?
-- ������� ������� Messages � ����� ��������

-- �������������� ���������:
-- "������ SQL Server �� ����������� ���������� ����������� ��� ORDER BY"
-- https://habr.com/ru/company/otus/blog/504144/
--
-- "������������� SET STATISTICS TIME ON � SQL Server"
-- https://habr.com/ru/company/otus/blog/572854/

-- -------------------------------
-- TOP WITH TIES
-- -------------------------------
-- ���� ����� TOP N ����� ����� ���� ����� �� ��������
-- � ��������, ��������� � ORDER BY, �� ��� ������ ��� �� ������������ 
-- ������������ ������ � ORDER BY

SELECT TOP 3 
    CityID, 
    CityName AS City, 
    CityName City2, 
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;

SELECT TOP 3 WITH TIES
    CityID, 
    CityName AS City, 
    CityName City2, 
    City3 = CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY City;
GO

-- -------------------------------
-- OFFSET - �������� �� ���������
-- � SQL Server 2012
-- -------------------------------

SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName;

SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY;
GO

-- ���������� OFFSET
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 10 ROWS;

-- ������������ �����
DECLARE 
    @pagesize BIGINT = 10, -- ������ ��������
    @pagenum  BIGINT = 3;  -- ����� ��������

SELECT 
    CityID, 
    CityName AS City,
    StateProvinceID
FROM Application.Cities
ORDER BY City, CityID
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY; 

-- � ���� �� ����� ORDER BY, �� ����� �� �������� OFFSET ?
/*
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
OFFSET 1 ROWS FETCH FIRST 5 ROWS ONLY;
*/


-- OFFSET - ��� ����� ORDER BY 
SELECT 
    CityID, 
    CityName,
    StateProvinceID
FROM Application.Cities
ORDER BY CityName
OFFSET 1 ROWS FETCH FIRST 5 ROWS ONLY;