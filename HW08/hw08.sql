/*
Задания выполняются с использованием базы данных WideWorldImporters.
Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak
Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/
drop table if exists #rows
create table #rows (id INT IDENTITY(1,1),Row_id int)
insert into Sales.Customers 
	(CustomerName, BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage,IsStatementSent
,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy)
output inserted.CustomerID into #rows (Row_id)
select 
top 5 
	CustomerName + ' new_' + cast(ROW_NUMBER() over(order by CustomerID) as varchar),	
	BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage,IsStatementSent
,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy
from sales.Customers 
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/
delete from sales.Customers where CustomerID = (
	select top 1 a.CustomerID from Sales.Customers as a
	join #rows as b on b.Row_id = a.CustomerID
	order by b.id)
/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update sales.Customers set PhoneNumber = '(999) 999-9999' where CustomerID = (
	select top 1 a.CustomerID from Sales.Customers as a
	join #rows as b on b.Row_id = a.CustomerID
	order by b.id)


/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS target 
	USING (
		select 
		top 1
		CustomerName,	
		BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage,IsStatementSent
		,IsOnCreditHold,PaymentDays,PhoneNumber = '(555) 555-5555',FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy
		from sales.Customers as a
		join #rows as r on r.Row_id = a.CustomerID
		) 
		AS source
		(CustomerName,	
		BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage,IsStatementSent
		,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy) 
		ON
	 (target.CustomerName = source.CustomerName) 
	WHEN MATCHED 
		THEN UPDATE SET PhoneNumber = source.PhoneNumber
	WHEN NOT MATCHED 
		THEN INSERT (CustomerName,	
			BillToCustomerID,CustomerCategoryID,PrimaryContactPersonID,DeliveryMethodID,DeliveryCityID,PostalCityID,AccountOpenedDate,StandardDiscountPercentage,IsStatementSent
			,IsOnCreditHold,PaymentDays,PhoneNumber,FaxNumber,WebsiteURL,DeliveryAddressLine1,DeliveryPostalCode,PostalAddressLine1,PostalPostalCode,LastEditedBy) 
		VALUES (
		source.CustomerName,	
		source.BillToCustomerID,
		source.CustomerCategoryID,
		source.PrimaryContactPersonID,
		source.DeliveryMethodID,
		source.DeliveryCityID,
		source.PostalCityID,
		source.AccountOpenedDate,
		source.StandardDiscountPercentage,
		source.IsStatementSent
		,source.IsOnCreditHold,
		source.PaymentDays,
		source.PhoneNumber,
		source.FaxNumber,
		source.WebsiteURL,
		source.DeliveryAddressLine1,
		source.DeliveryPostalCode,source.PostalAddressLine1,source.PostalPostalCode,source.LastEditedBy) 
	OUTPUT deleted.*, $action, inserted.*;
/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

--select top 10 
--CustomerID,CustomerName,DeliveryAddressLine1,PostalAddressLine1
--into bulc_demo_1
--from sales.Customers as a 

SELECT @@SERVERNAME
exec master..xp_cmdshell 'bcp "[WideWorldImporters].dbo.bulc_demo_1" out  "D:\bcp-out\bulc_demo.txt" -T -w -t"@eu&$1&" -S LEGION\SQL2022'


--USE [WideWorldImporters]
--GO
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--CREATE TABLE [dbo].[bulc_demo_in](
--	[CustomerID] [int] NOT NULL,
--	[CustomerName] [nvarchar](100) NOT NULL,
--	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
--	[PostalAddressLine1] [nvarchar](60) NOT NULL
--) ON [USERDATA]
--GO


BULK INSERT [WideWorldImporters].[dbo].[bulc_demo_in]
				FROM "D:\bcp-out\bulc_demo.txt"
				WITH 
					(
					BATCHSIZE = 1000, 
					DATAFILETYPE = 'widechar',
					FIELDTERMINATOR = '@eu&$1&',
					ROWTERMINATOR ='\n',
					KEEPNULLS,
					TABLOCK        
					);
select * from bulc_demo_1
select * from bulc_demo_in
