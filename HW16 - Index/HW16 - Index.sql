USE Income
-- ������� �������������� �������
CREATE FULLTEXT CATALOG WWI_FT_Catalog
WITH ACCENT_SENSITIVITY = ON
AS DEFAULT
AUTHORIZATION [dbo];
-- ON FILEGROUP
GO

-- ������� �������������� ������ �� StockItems
CREATE FULLTEXT INDEX ON Dict.StockItems(ItemName LANGUAGE Russian)
KEY INDEX PK_StockItems -- ��������� ����
ON (WWI_FT_Catalog)
WITH (
  CHANGE_TRACKING = AUTO, /* AUTO, MANUAL, OFF */
  STOPLIST = SYSTEM /* SYSTEM, OFF ��� ���������������� stoplist */
);
GO
--
ALTER TABLE Dict.StockItems ADD  CONSTRAINT [UQ_Dict_StockItems_ItemName] UNIQUE NONCLUSTERED 
	(
		[ItemName] ASC
	)
GO

-- ����� �� �����������, �������� ��������� � �������� � �����������.
SELECT id, ItemName
FROM Dict.StockItems 
WHERE CONTAINS (ItemName, N'FORMSOF(INFLECTIONAL, "������")');
GO  

--����������� ��� ������� ???
CREATE NONCLUSTERED INDEX [NCI_StockItemsSummaryMovements_StockItem_id] ON [Warehouse].[StockItemsSummary_Movements]
	(
		[StockItem_id] ASC
	)
-- ���������� �� ������.
-- ���� ������������ ��������, ����� �� �������������.
CREATE NONCLUSTERED INDEX [NCI_StockItemsSummary_Movements_Ad_Si] ON [Warehouse].[StockItemsSummary_Movements] 
(
	ActionDate ASC,
	StockItem_id asc
)

declare @StockItem_id int, @ActionDate_Start date, @ActionDate_End date
select top 1 @StockItem_id = a.id from dict.StockItems as a where a.ItemName = 'abc'

--������ ����� ��������� � ��������.
select 
[����] = a.ActionDate
,[��������] = a.hdr_delivery_id
,[���������] = b.FirstName + iif(b.SecondName is not null, ' ' + b.SecondName, '')
,[�����] = c.ItemName 
,[���������� ��] = a.BeforeQuantity
,[���������� �����] = a.AfterQuantity
from Warehouse.StockItemsSummary_Movements as a 
join dict.Employee as b on b.id = a.ActionEmployee_id -- ����������� ����� �� ��� �����. ���� ��� �������.
join dict.StockItems as c on c.id = a.StockItem_id --[NCI_StockItemsSummaryMovements_StockItem_id]
where 
ActionDate >= @ActionDate_Start 
and a.ActionDate < @ActionDate_End
and a.StockItem_id = @StockItem_id 

