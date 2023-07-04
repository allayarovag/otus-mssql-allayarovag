use WideWorldImporters;
--смотрим какие таблицы партиционированы
select distinct t.name
from sys.partitions p
inner join sys.tables t
	on p.object_id = t.object_id
where p.partition_number <> 1

--смотрим как конкретно по диапазонам распределились данные
SELECT  $PARTITION.fnCustomerTransactionsYearPartition([TransactionDate]) AS Partition
		, COUNT(*) AS [COUNT]
		, MIN([TransactionDate])
		,MAX([TransactionDate]) 
FROM Sales.[CustomerTransactionsPartitioned]
GROUP BY $PARTITION.fnCustomerTransactionsYearPartition([TransactionDate]) 
ORDER BY Partition ;  

select * from sys.partition_range_values;
select * from sys.partition_parameters;
select * from sys.partition_functions;

--можем посмотреть текущие границы
select	 f.name as NameHere
		,f.type_desc as TypeHere
		,(case when f.boundary_value_on_right=0 then 'LEFT' else 'Right' end) as LeftORRightHere
		,v.value
		,v.boundary_id
		,t.name from sys.partition_functions f
inner join  sys.partition_range_values v
	on f.function_id = v.function_id
inner join sys.partition_parameters p
	on f.function_id = p.function_id
inner join sys.types t
	on t.system_type_id = p.system_type_id
order by NameHere, boundary_id;

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [CustomerTransactionsYeardata]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\!!!Otus\partitions\CustomerTransactionsYeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [CustomerTransactionsYeardata]
GO

--создаем функцию партиционирования по годам - по умолчанию left!!
CREATE PARTITION FUNCTION [fnCustomerTransactionsYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');																																																									
GO

-- партиционируем, используя созданную функцию
CREATE PARTITION SCHEME [schmCustomerTransactionsYearPartition] AS PARTITION [fnCustomerTransactionsYearPartition] 
ALL TO ([CustomerTransactionsYeardata])
GO

--SELECT count(*) 
--FROM Sales.[CustomerTransactions];

--создаем таблицу для секционированния 
SELECT * INTO Sales.CustomerTransactionsPartitioned
FROM Sales.[CustomerTransactions];

--Через интерфейс:
CREATE CLUSTERED INDEX [ClusteredIndex_on_schmCustomerTransactionsYearPartition_638240759743829637] ON [Sales].[CustomerTransactionsPartitioned]
(
	[TransactionDate]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [schmCustomerTransactionsYearPartition]([TransactionDate])

--DROP INDEX [ClusteredIndex_on_schmCustomerTransactionsYearPartition_638240759743829637] ON [Sales].[CustomerTransactionsPartitioned]

-- на существующей таблице надо удалить кластерный индекс и создать новый кластерный индекс с ключом секционирования
-- можно создать через свойства таблицы -> хранилище

/*
--создадим новую партиционированную таблицу
CREATE TABLE [WideWorldImporters].[Sales].[CustomerTransactionsPartitioned](
	[CustomerTransactionID]
	,[CustomerID]
	,[TransactionTypeID]
	,[InvoiceID]
	,[PaymentMethodID]
	,[TransactionDate]
	,[AmountExcludingTax]
	,[TaxAmount]
	,[TransactionAmount]
	,[OutstandingBalance]
	,[FinalizationDate]
	,[IsFinalized]
	,[LastEditedBy]
	,[LastEditedWhen]
 
) ON [schmCustomerTransactionsYearPartition]([TransactionDate])---в схеме [schmCustomerTransactionsYearPartition] по ключу [TransactionDate]
GO

--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [Sales].[CustomerTransactionsPartitioned] ADD CONSTRAINT PK_Sales_CustomerTransactionsPartitioned
PRIMARY KEY CLUSTERED  (TransactionDate,CustomerTransactionID, InvoiceId)
 ON [schmCustomerTransactionsYearPartition]([TransactionDate]);
 */