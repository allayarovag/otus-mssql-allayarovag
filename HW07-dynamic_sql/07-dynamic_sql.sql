/*
��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.
��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.
���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.
������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/
DECLARE 
	@ColumnName AS NVARCHAR(MAX),
	@DynQuery AS NVARCHAR(MAX)
SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(CustomerName)
FROM (
	select distinct 
	b.CustomerName
	from sales.Orders as a
	join sales.Customers as b on b.CustomerID = a.CustomerID
    ) AS Cust

/*
select 
	@ColumnName = STUFF((SELECT ',' + QUOTENAME(CustomerName)
	from (
	select distinct 
	b.CustomerName
	from sales.Orders as a
	join sales.Customers as b on b.CustomerID = a.CustomerID
	) as a order by CustomerName
FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)')
,1,1,'')
*/

set @DynQuery = N'
SELECT 
	CONVERT (date,OrderMonth,104) as OrderMonth,
	' + @ColumnName + '
	FROM (
		select
		[CustomerName] = b.CustomerName
		,DATEADD(dd, -( DAY(a.OrderDate ) -1 ), a.OrderDate)  as OrderMonth
		,a.OrderID as Orders
		from sales.Orders as a
		join sales.Customers as b on b.CustomerID = a.CustomerID
	) AS Sales
PIVOT (count(Orders) FOR [CustomerName] IN 
	(' + @ColumnName + '))
as PVT
order by 1
'
exec sp_executesql @DynQuery;