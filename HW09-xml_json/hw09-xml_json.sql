/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "08 - ������� �� XML � JSON �����".

������� ����������� � �������������� ���� ������ WideWorldImporters.

����� �� ����� ������� ������:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
����� WideWorldImporters-Full.bak

�������� WideWorldImporters �� Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters;

/*
���������� � �������� 1, 2:
* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML. 
* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � ������� (��������, � https://data.gov.ru).
* ������ ��������/������� � ���� https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. � ������ �������� ���� ���� StockItems.xml.
��� ������ �� ������� Warehouse.StockItems.
������������� ��� ������ � ������� ������� � ������, ������������ Warehouse.StockItems.
����: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

��������� ��� ������ � ������� Warehouse.StockItems: 
������������ ������ � ������� ��������, ������������� �������� (������������ ������ �� ���� StockItemName). 

������� ��� ��������: � ������� OPENXML � ����� XQuery.
*/

DECLARE @xmlDocument XML;

-- ��������� XML-���� � ����������
-- !!! �������� ���� � XML-�����
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'D:\!!!Otus\Source_StockItems.xml', 
 SINGLE_CLOB)
AS data;

-- ���������, ��� � @xmlDocument
--SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

-- docHandle - ��� ������ �����
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
2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml
*/
/*
 <Item Name="&quot;The Gu&quot; red shirt XML tag t-shirt (Black) 3XXL">
    <SupplierID>4</SupplierID>
    <Package>
      <UnitPackageID>7</UnitPackageID>
      <OuterPackageID>6</OuterPackageID>
      <QuantityPerOuter>12</QuantityPerOuter>
      <TypicalWeightPerUnit>0.400</TypicalWeightPerUnit>
    </Package>
    <LeadTimeDays>7</LeadTimeDays>
    <IsChillerStock>0</IsChillerStock>
    <TaxRate>20.000</TaxRate>
    <UnitPrice>18.000000</UnitPrice>
*/

SELECT
	a.StockItemName		as [@Name],
	SupplierID			as [SupplierID],
	UnitPackageID		as [Package/UnitPackageID],
	OuterPackageID		as [Package/OuterPackageID],
	QuantityPerOuter	as [Package/QuantityPerOuter],
	TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	LeadTimeDays		as [LeadTimeDays],
	IsChillerStock		as [IsChillerStock],
	TaxRate				as [TaxRate],
	UnitPrice			as [UnitPrice]
FROM WideWorldImporters.Warehouse.StockItems as a 
FOR XML PATH('Item'), ROOT('StockItems')

declare @cmd varchar(4000) = 'bcp "SELECT a.StockItemName	as [@Name],	SupplierID	as [SupplierID],	UnitPackageID		as [Package/UnitPackageID],	OuterPackageID		as [Package/OuterPackageID],	QuantityPerOuter	as [Package/QuantityPerOuter],	TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],	LeadTimeDays		as [LeadTimeDays],	IsChillerStock		as [IsChillerStock],	TaxRate				as [TaxRate],	UnitPrice			as [UnitPrice] FROM [WideWorldImporters].[Warehouse].[StockItems] as a  FOR XML PATH(''Item''), ROOT(''StockItems'')" queryout  "D:\bcp-out\bulc_demo1.xml" -x -T  -w -S LEGION\SQL2022'
exec master..xp_cmdshell  @cmd

--exec master..xp_cmdshell 'bcp "select * from [WideWorldImporters].Warehouse.StockItems FOR XML PATH" queryout  "D:\bcp-out\bulc_demo.xml" -T -c -t -S LEGION\SQL2022'

/*
3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
�������� SELECT ��� ������:
- StockItemID
- StockItemName
- CountryOfManufacture (�� CustomFields)
- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)
*/

select top 100 
StockItemID, StockItemName, CustomFields,
JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
JSON_VALUE(CustomFields, '$.Tags[0]') AS FirstTag
from Warehouse.StockItems 

/*
4. ����� � StockItems ������, ��� ���� ��� "Vintage".
�������: 
- StockItemID
- StockItemName
- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

���� ������ � ���� CustomFields, � �� � Tags.
������ �������� ����� ������� ������ � JSON.
��� ������ ������������ ���������, ������������ LIKE ���������.

������ ���� � ����� ����:
... where ... = 'Vintage'

��� ������� �� �����:
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
