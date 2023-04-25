/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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

USE WideWorldImporters;

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

DECLARE @xmlDocument XML;

-- Считываем XML-файл в переменную
-- !!! измените путь к XML-файлу
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\!!!Otus\Source_StockItems.xml', 
 SINGLE_CLOB)
AS data;

-- Проверяем, что в @xmlDocument
--SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

-- docHandle - это просто число
--SELECT @docHandle AS docHandle;

SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	[StockItemName] nvarchar(500)  '@Name',
	[SupplierID] INT 'SupplierID',
	[UnitPackageID] INT 'Package/UnitPackageID',
    [OuterPackageID] INT 'Package/OuterPackageID', 
    [QuantityPerOuter]  INT 'Package/QuantityPerOuter', 
    [TypicalWeightPerUnit]  decimal(25,6) 'Package/TypicalWeightPerUnit',
    [LeadTimeDays] int 'LeadTimeDays',
    [IsChillerStock] int 'IsChillerStock',
    [TaxRate] decimal(25,6) 'TaxRate',
    [UnitPrice] decimal(25,6) 'UnitPrice');

SELECT  
	t.Supplier.value('(@Name)[1]', 'varchar(500)')				AS [StockItemName],
	t.Supplier.value('(SupplierID)[1]', 'int')					AS [SupplierID],
	t.Supplier.value('(Package/UnitPackageID)[1]', 'int')		AS [UnitPackageID],
	t.Supplier.value('(Package/OuterPackageID)[1]', 'int')		AS [OuterPackageID],
	t.Supplier.value('(Package/QuantityPerOuter)[1]', 'int')	AS [QuantityPerOuter],
	t.Supplier.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(25,6)') AS [TypicalWeightPerUnit],
	t.Supplier.value('(LeadTimeDays)[1]', 'int')				AS [LeadTimeDays],
	t.Supplier.value('(IsChillerStock)[1]', 'int')				AS [IsChillerStock],
	t.Supplier.value('(TaxRate)[1]', 'decimal(25,6)')			AS [TaxRate],
	t.Supplier.value('(UnitPrice)[1]', 'decimal(25,6)')			AS [UnitPrice]
FROM @xmlDocument.nodes('/StockItems/Item') AS t(Supplier);
   
MERGE Warehouse.StockItems AS target 
	USING (
		SELECT *
        FROM OPENXML(@docHandle, N'/StockItems/Item')
        WITH ( 
            [StockItemName] nvarchar(500)  '@Name',
            [SupplierID] INT 'SupplierID',
            [UnitPackageID] INT 'Package/UnitPackageID',
            [OuterPackageID] INT 'Package/OuterPackageID', 
            [QuantityPerOuter]  INT 'Package/QuantityPerOuter', 
            [TypicalWeightPerUnit]  decimal(25,6) 'Package/TypicalWeightPerUnit',
            [LeadTimeDays] int 'LeadTimeDays',
            [IsChillerStock] int 'IsChillerStock',
            [TaxRate] decimal(25,6) 'TaxRate',
            [UnitPrice] decimal(25,6) 'UnitPrice')
		) 
		AS source
		(StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice ) 
		ON
	 (target.StockItemName = source.StockItemName) 
	WHEN MATCHED 
		THEN UPDATE 
            SET 
			SupplierID				= source.SupplierID,
            UnitPackageID			= source.UnitPackageID,
			OuterPackageID			= source.OuterPackageID, 
			QuantityPerOuter		= source.QuantityPerOuter, 
			TypicalWeightPerUnit	= source.TypicalWeightPerUnit,
			LeadTimeDays			= source.LeadTimeDays,
			IsChillerStock			= source.IsChillerStock, 
			TaxRate					= source.TaxRate, 
			UnitPrice				= source.UnitPrice,
			LastEditedBy			= 1
			--, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 
	WHEN NOT MATCHED 
		THEN INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice,LastEditedBy) 
		VALUES 
		(StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice,1)
		OUTPUT deleted.*, $action, inserted.*;

EXEC sp_xml_removedocument @docHandle;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

exec master..xp_cmdshell 'bcp "select * from [WideWorldImporters].Warehouse.StockItems FOR XML PATH" queryout  "D:\bcp-out\bulc_demo.xml" -T -c -t -S LEGION\SQL2022'

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select top 100 
StockItemID, StockItemName, CustomFields,
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
from Warehouse.StockItems 

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/
select top 100 
StockItemID, StockItemName, CustomFields,
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
from Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags
where 
tags.value = 'Vintage'
