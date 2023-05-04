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
Сотрудники
Группы сотрудников
Дебиторы
Города
Товары
Заголовки заказов
Табличная часть заказов
*/


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

---- удаление базы данных
--drop database if exists [Income];

use [Income]

--Группы сотрудников
CREATE TABLE dbo.WorkerGroups (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NULL,
	[GroupName]		[varchar](255) NOT NULL,
	[ExternalCode]	[varchar](255) NOT NULL,
CONSTRAINT UQ_FullNameTelefonEmail UNIQUE([id], [ExternalCode]),
CONSTRAINT [PK_WorkerGroups] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE dbo.WorkerGroups ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Работяги
CREATE TABLE dbo.Workers (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NULL,
	[FirstName]		[varchar](255) NOT NULL,
	[SecondName]	[varchar](255) NULL,
	[ExternalCode]	[varchar](255) NOT NULL,
	[PhoneNummer]	[int] NOT NULL,
	[Email]			[varchar](250) NOT NULL,
	[WorkerGroup_id]	[int] NOT NULL,
CONSTRAINT UQ_Workers UNIQUE([id], [FirstName], [SecondName], [Email]),
CONSTRAINT [PK_Workers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON,OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO

ALTER TABLE dbo.Workers ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

ALTER TABLE dbo.Workers  WITH CHECK ADD  CONSTRAINT [FK_Workers_WorkerGroups_id] FOREIGN KEY([WorkerGroup_id])
REFERENCES [dbo].[WorkerGroups] ([id])
GO

ALTER TABLE [dbo].Workers CHECK CONSTRAINT [FK_Workers_WorkerGroups_id]
GO

--Города
CREATE TABLE dbo.Cities (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[CityName]		[varchar](255) NOT NULL
CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE dbo.Cities ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Дебиторы
CREATE TABLE dbo.Debtors (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[DebtorName]	[varchar](255) NOT NULL,
	[City_id]		[int] NOT NULL,
CONSTRAINT [PK_Debtors] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE dbo.Debtors ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE dbo.Debtors  WITH CHECK ADD  CONSTRAINT [FK_Debtors_City_id] FOREIGN KEY([City_id])
REFERENCES [dbo].[Cities] ([id])
GO

ALTER TABLE [dbo].Debtors CHECK CONSTRAINT [FK_Debtors_City_id]
GO

--Товары
CREATE TABLE dbo.StockItems (
	[id]			[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]	[datetime2] NOT NULL,
	[ItemName]		[varchar](500) NOT NULL
CONSTRAINT [PK_StockItems] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE dbo.StockItems ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

--Заголовки заказов
CREATE TABLE dbo.hdr_Delivery (
	[id]				[int]  IDENTITY(1,1) NOT NULL,
	[RecordDate]		[datetime2] NOT NULL,
	[DocumentNumber]	[varchar](255) NOT NULL,
	[Debtor_id]			[int] NOT NULL,
	[TargetDebtor_id]	[int] NOT NULL,
CONSTRAINT [PK_hdr_Delivery] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH 
	(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, 	IGNORE_DUP_KEY = OFF,	ALLOW_ROW_LOCKS = ON, 	ALLOW_PAGE_LOCKS = ON,	OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)	ON [PRIMARY]) ON [PRIMARY]
GO
ALTER TABLE dbo.hdr_Delivery ADD  DEFAULT (getdate()) FOR [RecordDate]
GO
ALTER TABLE dbo.hdr_Delivery  WITH CHECK ADD  CONSTRAINT [FK_hdr_Delivery_Debtor_id] FOREIGN KEY([Debtor_id])
REFERENCES [dbo].[Debtors] ([id])
GO
ALTER TABLE [dbo].hdr_Delivery CHECK CONSTRAINT [FK_hdr_Delivery_Debtor_id]
GO

ALTER TABLE dbo.hdr_Delivery  WITH CHECK ADD  CONSTRAINT [FK_hdr_Delivery_TargetDebtor_id] FOREIGN KEY([TargetDebtor_id])
REFERENCES [dbo].[Debtors] ([id])
GO
ALTER TABLE [dbo].hdr_Delivery CHECK CONSTRAINT [FK_hdr_Delivery_TargetDebtor_id]
GO

--Табличная часть заказов
CREATE TABLE dbo.tbl_Delivery (
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

ALTER TABLE dbo.tbl_Delivery ADD  DEFAULT (getdate()) FOR [RecordDate]
GO

CREATE NONCLUSTERED INDEX [NCI_tbl_Delivery_Delivery_id] ON [dbo].[tbl_Delivery]
(
	[Delivery_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

ALTER TABLE dbo.tbl_Delivery  WITH CHECK ADD  CONSTRAINT [FK_tbl_Delivery_Delivery_id] FOREIGN KEY([Delivery_id])
REFERENCES [dbo].[hdr_Delivery] ([id])
GO
ALTER TABLE [dbo].tbl_Delivery CHECK CONSTRAINT [FK_tbl_Delivery_Delivery_id]
GO

ALTER TABLE dbo.tbl_Delivery  WITH CHECK ADD  CONSTRAINT [FK_tbl_Delivery_StockItem_id] FOREIGN KEY([StockItem_id])
REFERENCES [dbo].[StockItems] ([id])
GO
ALTER TABLE [dbo].tbl_Delivery CHECK CONSTRAINT [FK_tbl_Delivery_StockItem_id]
GO
