/*Начало проектной работы. 
Создание таблиц и представлений для своего проекта.

Нужно написать операторы DDL для создания БД вашего проекта:
1. Создать базу данных.
2. 3-4 основные таблицы для своего проекта. 
3. Первичные и внешние ключи для всех созданных таблиц.
4. 1-2 индекса на таблицы.
5. Наложите по одному ограничению в каждой таблице на ввод данных.

Обязательно (если еще нет) должно быть описание предметной области. */

/*
Сотрудники			- Employee
Группы сотрудников	- EmployeeGroups
Дебиторы			- Debtors
Города				- Cities 
StockItems			- Товары
hdr_Delivery		- Заголовки заказов
tbl_Delivery		- Табличная часть заказов

[RecordDate] - Дата создания записи, значение по умолчанию getdate() - требование бизнеса.
*/

/*
drop table if exists Supply.tbl_Delivery
drop table if exists Supply.hdr_Delivery
drop table if exists Dict.StockItems
drop table if exists Dict.Debtors
drop table if exists dbo.Cities
drop table if exists Dict.Employee
drop table if exists Dict.EmployeeGroups
*/

/*
create schema [Dict]
go
create schema [Warehouse]
go
create schema [Supply]
go
*/

/*
declare @CurrUser nvarchar(100)
set @CurrUser = CURRENT_USER
select @CurrUser

CREATE DATABASE [Income]
ON  PRIMARY 
( NAME = test2, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\DATA\Income.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = test2_log, FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQL2022\MSSQL\DATA\Income.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 1GB , 
	FILEGROWTH = 65536KB )
COLLATE SQL_Latin1_General_CP1251_CI_AS
GO
*/

---- удаление базы данных
--drop database if exists [Income];

use [Income]

--Группы сотрудников
CREATE TABLE [Dict].EmployeeGroups (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NULL,
	[GroupName]		[nvarchar](255) NOT NULL,
	[ExternalCode]	[nvarchar](255) NOT NULL,
CONSTRAINT UQ_FullNameTelefonEmail UNIQUE([id], [ExternalCode]),
CONSTRAINT [PK_EmployeeGroups] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE [Dict].EmployeeGroups ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Сотрудники
CREATE TABLE [Dict].Employee (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NULL,
	[FirstName]		[nvarchar](255) NOT NULL,
	[SecondName]	[nvarchar](255) NULL,
	[ExternalCode]	[nvarchar](255) NOT NULL,
	[PhoneNummer]	[int] NOT NULL,
	[Email]			[nvarchar](250) NOT NULL,
	[WorkerGroup_id]	[int] NOT NULL,
CONSTRAINT UQ_Employee UNIQUE([id], [FirstName], [SecondName], [Email]),
CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO

ALTER TABLE [Dict].Employee ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

ALTER TABLE [Dict].Employee  WITH CHECK ADD  CONSTRAINT [FK_Employee_EmployeeGroups_id] FOREIGN KEY([WorkerGroup_id])
REFERENCES [Dict].[EmployeeGroups] ([id])
GO

ALTER TABLE [Dict].Employee CHECK CONSTRAINT [FK_Employee_EmployeeGroups_id]
GO

--Города
CREATE TABLE [Dict].Cities (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[CityName]		[nvarchar](255) NOT NULL
CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE [Dict].Cities ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Дебиторы
CREATE TABLE [Dict].Debtors (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[DebtorName]	[nvarchar](255) NOT NULL,
	[City_id]		[int] NOT NULL,
CONSTRAINT [PK_Debtors] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE [Dict].Debtors ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [Dict].Debtors  WITH CHECK ADD  CONSTRAINT [FK_Debtors_City_id] FOREIGN KEY([City_id])
REFERENCES [Dict].[Cities] ([id])
GO

ALTER TABLE [Dict].Debtors CHECK CONSTRAINT [FK_Debtors_City_id]
GO

--Товары
CREATE TABLE [Dict].StockItems (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[ItemName]		[nvarchar](500) NOT NULL
CONSTRAINT [PK_StockItems] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE [Dict].StockItems ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Заголовки заказов
CREATE TABLE [Supply].hdr_Delivery (
	[id]				[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]		[datetime2] NOT NULL,
	[DocumentNumber]	[nvarchar](255) NOT NULL,
	[Debtor_id]			[int] NOT NULL,
	[TargetDebtor_id]	[int] NOT NULL,
CONSTRAINT [PK_hdr_Delivery] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE [Supply].hdr_Delivery ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE [Supply].hdr_Delivery  WITH CHECK ADD  CONSTRAINT [FK_hdr_Delivery_Debtor_id] FOREIGN KEY([Debtor_id])
REFERENCES [Dict].[Debtors] ([id])
GO
ALTER TABLE [Supply].hdr_Delivery CHECK CONSTRAINT [FK_hdr_Delivery_Debtor_id]
GO

ALTER TABLE [Supply].hdr_Delivery  WITH CHECK ADD  CONSTRAINT [FK_hdr_Delivery_TargetDebtor_id] FOREIGN KEY([TargetDebtor_id])
REFERENCES [Dict].[Debtors] ([id])
GO
ALTER TABLE [Supply].hdr_Delivery CHECK CONSTRAINT [FK_hdr_Delivery_TargetDebtor_id]
GO

--Табличная часть заказов
CREATE TABLE [Supply].tbl_Delivery (
	[id]				[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]		[datetime2] NOT NULL,
	[Delivery_id]		[int] NOT NULL,
	[StockItem_id]		[int] NOT NULL,
	[Quantity]			[decimal](25,6) NOT NULL,
CONSTRAINT [PK_tbl_Delivery] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO

ALTER TABLE [Supply].tbl_Delivery ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

CREATE NONCLUSTERED INDEX [NCI_tbl_Delivery_Delivery_id] ON [Supply].[tbl_Delivery]
(
	[Delivery_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

ALTER TABLE [Supply].tbl_Delivery  WITH CHECK ADD  CONSTRAINT [FK_tbl_Delivery_Delivery_id] FOREIGN KEY([Delivery_id])
REFERENCES [Supply].[hdr_Delivery] ([id])
GO
ALTER TABLE [Supply].tbl_Delivery CHECK CONSTRAINT [FK_tbl_Delivery_Delivery_id]
GO

ALTER TABLE [Supply].tbl_Delivery  WITH CHECK ADD  CONSTRAINT [FK_tbl_Delivery_StockItem_id] FOREIGN KEY([StockItem_id])
REFERENCES [Dict].[StockItems] ([id])
GO
ALTER TABLE [Supply].tbl_Delivery CHECK CONSTRAINT [FK_tbl_Delivery_StockItem_id]
GO

/*
StorageObjects				- Объекты складирования(тара - ящики, палеты и тд. Пока без типов)
StockItemsSummary			- остатки
tbl_Income					- Лог приемки
StockItemsQuality			- Качество товара
StockItemsBatch				- Партии товара
StockItemsSummary_Movements	- Движение товара
*/

--Объекты складирования(тара - ящики, палеты и тд. Пока без типов)
	CREATE TABLE [Warehouse].StorageObjects (
		[id]					[int]  IDENTITY(1,1) NOT NULL,
		[RecordDate]			[datetime2] NOT NULL,
		[StorageObjectBarcode]	[nvarchar](100) NOT NULL
	CONSTRAINT [PK_StockItems] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO
	ALTER TABLE [Warehouse].StorageObjects ADD  DEFAULT (getdate()) FOR [RecordDate]
	GO

--StockItemsQuality			- Качество товара
	CREATE TABLE [Dict].[StockItemsQuality] (
		[id]					[int]  IDENTITY(1,1) NOT NULL,
		[RecordDate]			[datetime2] NOT NULL,
		[QualityName]			[nvarchar](100) NOT NULL
	CONSTRAINT [PK_StockItemsQuality] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO

	ALTER TABLE [Dict].[StockItemsQuality] ADD  DEFAULT (getdate()) FOR [RecordDate]
	GO
	
--StockItemsBatch				- Партии товара
	CREATE TABLE [Warehouse].[StockItemsBatch] (
		[id]				[int]  IDENTITY(1,1) NOT NULL,
		[RecordDate]		[datetime2] NOT NULL,
		[tbl_delivery_id]	[int] NOT NULL,
		[StockItem_id]		[int] NOT NULL,
		[ProductionDate]	[datetime2] NULL,
		[ValidUntil]		[datetime2] NULL,
		[ValidDays]			[int] NULL,
	CONSTRAINT [PK_StockItemsBatch] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsBatch_id] ON [Warehouse].[StockItemsBatch]
	(
		[id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	GO

	ALTER TABLE [Warehouse].[StockItemsBatch]  WITH CHECK ADD  CONSTRAINT [FK_StockItemsBatch_tbl_Delivery] FOREIGN KEY([tbl_delivery_id])
	REFERENCES [Supply].[tbl_Delivery] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsBatch] CHECK CONSTRAINT [FK_StockItemsBatch_tbl_Delivery]
	GO

	ALTER TABLE [Warehouse].[StockItemsBatch]  WITH CHECK ADD  CONSTRAINT [FK_StockItemsBatch_StockItem_id] FOREIGN KEY([StockItem_id])
	REFERENCES [Dict].[StockItems] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsBatch] CHECK CONSTRAINT [FK_StockItemsBatch_StockItem_id]
	GO

--StockItemsSummary			- остатки 
	CREATE TABLE [Warehouse].[StockItemsSummary] (
		[id]				[int]  IDENTITY(1,1) NOT NULL,
		[LastEditedDate]	[datetime2] NOT NULL,
		[StorageObject_id]	[int] NOT NULL,
		[StockItem_id]		[int] NOT NULL,
		[Quantity]			[int] NOT NULL,
		[Quality_id]		[int] NOT NULL,
		[Batch_id]			[int] NOT NULL,
	CONSTRAINT [PK_StockItemsSummary] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsSummary_StorageObject_id] ON [Warehouse].[StockItemsSummary]
	(
		[StorageObject_id] ASC
	)
	INCLUDE([StockItem_id],[Quantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsSummary_Material_id] ON [Warehouse].[StockItemsSummary]
	(
		[StockItem_id] ASC
	)
	INCLUDE([Batch_id],[StorageObject_id],[Quality_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	GO

	ALTER TABLE [Warehouse].[StockItemsSummary] WITH CHECK ADD  CONSTRAINT [FK_StockItemsSummary_StorageObject_id] FOREIGN KEY([StorageObject_id])
	REFERENCES [Warehouse].[StorageObjects] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsSummary] CHECK CONSTRAINT [FK_StockItemsSummary_StorageObject_id]
	GO

	ALTER TABLE [Warehouse].[StockItemsSummary] WITH CHECK ADD  CONSTRAINT [FK_StockItemsSummary_StockItem_id] FOREIGN KEY([StockItem_id])
	REFERENCES [Dict].[StockItems] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsSummary] CHECK CONSTRAINT [FK_StockItemsSummary_StockItem_id]
	GO

	ALTER TABLE [Warehouse].[StockItemsSummary] WITH CHECK ADD  CONSTRAINT [FK_StockItemsSummary_Quality_id] FOREIGN KEY([Quality_id])
	REFERENCES [Dict].[StockItemsQuality] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsSummary] CHECK CONSTRAINT [FK_StockItemsSummary_Quality_id]
	GO

	ALTER TABLE [Warehouse].[StockItemsSummary] WITH CHECK ADD  CONSTRAINT [FK_StockItemsSummary_Batch_id] FOREIGN KEY([Batch_id])
	REFERENCES [Warehouse].[StockItemsBatch] ([id])
	GO
	ALTER TABLE [Warehouse].[StockItemsSummary] CHECK CONSTRAINT [FK_StockItemsSummary_Batch_id]
	GO

--StockItemsSummary_Movements	- Движение товара
	CREATE TABLE [Warehouse].[StockItemsSummary_Movements] (
		[id]				[int]  IDENTITY(1,1) NOT NULL,
		[ActionDate]		[datetime2] NOT NULL,
		[hdr_delivery_id]	[int] NOT NULL,
		[ActionEmployee_id] [int] NOT NULL,
		[StorageObject_id]	[int] NOT NULL,
		[StockItem_id]		[int] NOT NULL,
		[BeforeQuantity]	[int] NOT NULL,
		[AfterQuantity]		[int] NOT NULL,
		[Quality_id]		[int] NOT NULL,
		[Batch_id]			[int] NOT NULL,
	CONSTRAINT [PK_StockItemsSummary_Movements] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO

	ALTER TABLE [Warehouse].[StockItemsSummary_Movements] ADD  DEFAULT (getdate()) FOR [ActionDate]
	GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsSummaryMovements_StorageObject_id] ON [Warehouse].[StockItemsSummary_Movements]
	(
		[StorageObject_id] ASC
	)
	--INCLUDE([id],[BeforeQuantity],[AfterQuantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	--GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsSummaryMovements_StockItem_id] ON [Warehouse].[StockItemsSummary_Movements]
	(
		[StockItem_id] ASC
	)
	--INCLUDE([Batch_id],[StorageObject_id],[Quality_id],[BeforeQuantity],[AfterQuantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	--GO

	CREATE NONCLUSTERED INDEX [NCI_StockItemsSummaryMovements_ActionDate] ON [Warehouse].[StockItemsSummary_Movements] -- Понадобится для отчетов за период.
	(
		[ActionDate] ASC
	)

--Табличная часть приемки товара.
CREATE TABLE [Warehouse].[tbl_Income] (
		[id]				[int]  IDENTITY(1,1) NOT NULL,
		[ActionDate]		[datetime2] NOT NULL,
		[hdr_delivery_id]	[int] NOT NULL,
		[ActionEmployee_id] [int] NOT NULL,
		[StorageObject_id]	[int] NOT NULL,
		[StockItem_id]		[int] NOT NULL,
		[Quantity]			[int] NOT NULL,
		[Quality_id]		[int] NOT NULL,
		[Batch_id]			[int] NOT NULL,
	CONSTRAINT [PK_tbl_Income] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH 
		(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
	GO

	ALTER TABLE [Warehouse].[tbl_Income] ADD  DEFAULT (getdate()) FOR [ActionDate]
	GO

	CREATE NONCLUSTERED INDEX [NCI_tbl_Income_StorageObject_id]
	ON [Warehouse].[tbl_Income]
	(
		[StorageObject_id] ASC
	)
	--INCLUDE([id],[BeforeQuantity],[AfterQuantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	--GO

	CREATE NONCLUSTERED INDEX [NCI_tbl_Income_StockItem_id] 
	ON [Warehouse].[tbl_Income]
	(
		[StockItem_id] ASC
	)
	--INCLUDE([Batch_id],[StorageObject_id],[Quality_id],[BeforeQuantity],[AfterQuantity]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	--GO

	CREATE NONCLUSTERED INDEX [NCI_tbl_Income_ActionDate] 
	ON [Warehouse].[tbl_Income] -- Понадобится для отчетов за период. Отчет будет требовать период в обязательном порядке.
	(
		[ActionDate] ASC
	)
	INCLUDE([ActionEmployee_id],[StockItem_id],[StorageObject_id] ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = ON, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
	GO

/*Триггер остатков, создание движения*/
USE Income
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Warehouse].[tg_StockItemsSummary] on [Warehouse].[StockItemsSummary] after insert, update
as
	insert into Warehouse.StockItemsSummary_Movements 
		(ActionEmployee_id,
		ActionDate,
		StorageObject_id, 
		StockItem_id, 
		BeforeQuantity,
		AfterQuantity,
		Quality_id, 
		Batch_id)
	select 
		a.ToMoveEmployee_id,
		getdate(),
		a.StorageObject_id,
		a.StockItem_id,
		isnull(b.Quantity,0),
		a.Quantity,
		a.Quality_id,
		a.Batch_id
	from inserted as a
	left join deleted as b on a.id = b.id
GO

ALTER TABLE [Warehouse].[StockItemsSummary] ENABLE TRIGGER [tg_StockItemsSummary]
GO

--insert into  [Warehouse].[StockItemsSummary]
--(LastEditedDate,	StorageObject_id,	StockItem_id,	Quantity,	Quality_id,	Batch_id,	ToMoveEmployee_id)
--values
--(getdate(), 1,1,1,1,1,1)



declare @StockItem_id int
select top 1 @StockItem_id = a.id from dict.StockItems as a where a.ItemName = 'abc'

/*
SELECT id, ItemName
FROM dict.StockItems 
WHERE CONTAINS (ItemName, N'FORMSOF(INFLECTIONAL, "кошка")');
*/

select 
[Дата] = a.ActionDate
,[Поставка] = a.hdr_delivery_id
,[Сотрудник] = b.FirstName + iif(b.SecondName is not null, ' ' + b.SecondName, '')
,[Товар] = c.ItemName 
,[Количество До] = a.BeforeQuantity
,[Количество После] = a.AfterQuantity
from Warehouse.StockItemsSummary_Movements as a 
join dict.Employee as b on b.id = a.ActionEmployee_id
join dict.StockItems as c on c.id = a.StockItem_id
where a.StockItem_id = @StockItem_id
Go
/*Процедура создания ОС*/
/*
Create or Alter PROCEDURE dbo.[Pr_Create_StorageObjects]
(
	@Quantity int
)
as begin
	set nocount on
	if @Quantity > 10 
	begin
		select [ОШИБКА] = 'Запрещено создавать больше 10 объектов складирования'
		goto terminate
	end

	declare @Counts int, @tid int
	declare @Rows table (tid int)

	set @Counts = 0
	while @Counts < @Quantity
	begin
		delete from @Rows
		insert into Warehouse.StorageObjects (StorageObjectBarcode)
		output inserted.id into @Rows(tid)
		select NEWID()

		select top 1 @tid = tid from @Rows
		update Warehouse.StorageObjects set StorageObjectBarcode = 'SO' + right('000000' + CAST(id as nvarchar),6) where id = @tid
		set @Counts = @Counts + 1
	end
	select [Успешно] = 'Создано ' + cast(@Counts as nvarchar) + ' Объектов складирования'
terminate:
end
*/
/*
--Создаем, пробуем больше 10 = ошибка, ограничиваем не больше 10
exec dbo.Pr_Create_StorageObjects 
	@quantity = 5
*/
select * from Warehouse.StorageObjects

	--insert into Dict.Cities (CityName)
	--values 
	--('Москва'),
	--('Санкт-Петербург'),
	--('Нижний Новгород'),
	--('Екатеринбург'),
	--('Выборг'),
	--('Казань'),
	--('Перьм'),
	--('Сочи')
select * from Dict.Cities

	--insert into Dict.Debtors(DebtorName,City_id)
	--values 
	--('Ситилинк',	(select top 1 id from Dict.Cities order by newid())),
	--('yota',		(select top 1 id from Dict.Cities order by newid())),
	--('MailGroup',	(select top 1 id from Dict.Cities order by newid())),
	--('Мегафон',	(select top 1 id from Dict.Cities order by newid())),
	--('Открытие',	(select top 1 id from Dict.Cities order by newid())),
	--('Почта России',(select top 1 id from Dict.Cities order by newid())),
	--('Росбанк',	(select top 1 id from Dict.Cities order by newid())),
	--('Яндекс',	(select top 1 id from Dict.Cities order by newid())),
	--('Яндекс',	(select top 1 id from Dict.Cities order by newid())),
	--('Отус',		(select top 1 id from Dict.Cities order by newid())),
	--('Skillbox',	(select top 1 id from Dict.Cities order by newid())),
	--('Сбербанк',	(select top 1 id from Dict.Cities order by newid()))

select * from Dict.Debtors 

/*Добавлены константы*/

	--CREATE TABLE dbo.Constants(
	--	[id] [int] IDENTITY(1,1) NOT NULL,
	--	[RecordDate] [datetime2](7) NOT NULL,
	--	[ConstantName] [nvarchar](255) NOT NULL,
	--	[ConstantExternalCode] [nvarchar](255) NOT NULL,
	--	[ConstantValue] [nvarchar](255) NOT NULL,
	-- CONSTRAINT [PK_Constants] PRIMARY KEY CLUSTERED 
	--(
	--	[id] ASC
	--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	--) ON [PRIMARY]

	--ALTER TABLE dbo.Constants ADD  DEFAULT (getdate()) FOR [RecordDate]
	--GO

/*Триггер баз данных*/
select * from income.dbo.DB_ddl_log
	--insert into dbo.Constants (ConstantName,ConstantExternalCode,ConstantValue)
	--values ('Качество по умолчанию', 'DefaultQuality', 1) --Пока не заморачиваюсь

/*Получаем значение по умолчанию*/
	--CREATE FUNCTION dbo.fn_GetConstant
	--(
	-- @ConstantExternalCode varchar(255)
	--)
	--returns varchar(255)
	--as begin
	--	declare @ConstantValue varchar(255)
	--	select @ConstantValue = ConstantValue from Constants where ConstantExternalCode = @ConstantExternalCode
	--	return @ConstantValue	
	--end

select dbo.fn_GetConstant('DefaultQuality')

--select suser_sname()

/*Заполняем заголовки заказов.*/
	/*
	declare @Quantity int = 100
	declare @Counts int, @tid int
	declare @Rows table (tid int)

	set @Counts = 0
	while @Counts < @Quantity
	begin
		delete from @Rows
		insert into Supply.hdr_Delivery
		(DocumentNumber,Debtor_id, TargetDebtor_id)
			output inserted.id into @Rows(tid)
		select NEWID(),
		(select top 1 id from Dict.Debtors order by newid()),
		10 --По умолчанию поставщик отус

		select top 1 @tid = tid from @Rows
		update Supply.hdr_Delivery set DocumentNumber = 'DOC' + right('000000' + CAST(id as nvarchar),6) where id = @tid
		set @Counts = @Counts + 1
	end
	select [Успешно] = 'Создано ' + cast(@Counts as nvarchar) + ' Заказов'
	*/

/*Добавил количество строк в заказе*/
	--alter table Income.Supply.hdr_Delivery add PositionsCount int null

/*Залил товары из WWi...*/
	/*
	declare @Quantity int = 1000
	declare @Counts int, @tid int
	declare @Rows table (tid int)

	set @Counts = 0
	while @Counts < @Quantity
	begin
		delete from @Rows
		insert into dict.StockItems (ItemName)
		select StockItemName 
		from WideWorldImporters.Warehouse.StockItems as a 
		where a.StockItemName collate DATABASE_DEFAULT  not in (select b.ItemName collate DATABASE_DEFAULT from dict.StockItems as b) 
		order by newid()
		set @Counts = @Counts + 1
	end
	select count(*) from dict.StockItems
	*/

/*Определяем колиество строк в заказе, случайно, затем будем заполнять табличную часть*/
	--declare @Qq int, @id int
	--declare K cursor local fast_forward for
	--select id from Income.Supply.hdr_Delivery
	
	--open K
	--fetch next from K into @id
	--while @@fetch_status = 0
	--begin
	--	update Supply.hdr_Delivery set PositionsCount = FLOOR(RAND()*(10))+1 where id = @id
	--	fetch next from K into @id
	--end
	--close K
	--deallocate K

--Заливаем данные
--declare @DynSQL varchar(max)
--declare @Quantity int = 1000, @MaxQuantity int = 30
--declare @Counts int, @tid int
--declare @Rows table (tid int)
--declare @id int

--declare K cursor local fast_forward for
--	select id,PositionsCount from Income.Supply.hdr_Delivery
	
--	open K
--	fetch next from K into @id,@Quantity
--	while @@fetch_status = 0
--	begin
		
--	delete from @Rows
--	set @Counts = 0

--	while @Counts < @Quantity
--	begin
--		insert into Supply.tbl_Delivery (Delivery_id, StockItem_id, Quantity)
--			output inserted.StockItem_id into @Rows (tid)
--		select top 1 @id,id, FLOOR(RAND()*(@MaxQuantity))+1
--			from Dict.StockItems 
--			where id not in (select tid from @Rows)
--			order by newid()

--		set @Counts = @Counts + 1
--	end
	
--		Update Supply.tbl_Delivery set RecordDate = dateadd(DAY,FLOOR(RAND()*(30))+1,RecordDate) where Delivery_id = @id
--		fetch next from K into @id,@Quantity
--	end
--	close K
--	deallocate K

select * from Supply.tbl_Delivery

