ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;

USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  
	WITH ROLLBACK 
	IMMEDIATE; 
--Неуточненные транзакции проходят откат. Предварительно выполнение отката: 0%.
--Неуточненные транзакции проходят откат. Предварительно выполнение отката: 100%.
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;
--для разных инстансов надо будет по другому

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--An exception occurred while enqueueing a message in the target queue. Error: 33009, State: 2. 
--The database owner SID recorded in the master database differs from the database owner SID recorded in database 'WideWorldImporters'. 
--You should correct this situation by resetting the owner of database 'WideWorldImporters' using the ALTER AUTHORIZATION statement.

create table ReportCustomersOrders (
id int identity(0,1) primary key,
CustomerID	int,
OrderCOUNTS int,
StartDate	date,
EndDate		date,
InsertedDate datetime2 
	default getdate()
)


--Create Message Types for Request and Reply messages
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[ReportRequestMessage]
VALIDATION=WELL_FORMED_XML; --Для json убрать 
-- For Reply
CREATE MESSAGE TYPE
[ReportReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO

CREATE CONTRACT [ReportContract]
      ([ReportRequestMessage]
         SENT BY INITIATOR,
       [ReportReplyMessage]
         SENT BY TARGET
      );
GO

--
CREATE QUEUE TargetQueueReport;

CREATE SERVICE TargetSERVICEReport
       ON QUEUE TargetQueueReport
       ([ReportContract]);
GO


CREATE QUEUE InitiatorQueueReport;

CREATE SERVICE InitiatorSERVICEReport
       ON QUEUE InitiatorQueueReport
       ([ReportContract]);
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE dbo.ReportParams
	@CustomerID INT,
	@StartDate date,
	@EndDate date
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN 

	--Сообщение
	SELECT @RequestMessage = (SELECT [CustomerID] = @CustomerID,
									 [StartDate] = @StartDate,
									 [EndDate] = @EndDate
							   FOR XML RAW, root('RequestMessage')); 
							   
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[InitiatorSERVICEReport]
	TO SERVICE
	'TargetSERVICEReport'
	ON CONTRACT
	[ReportContract]
	WITH ENCRYPTION=OFF; 

	--Отправляем сообщение
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[ReportRequestMessage]
	(@RequestMessage);
	SELECT @RequestMessage AS SentRequestMessage;
	COMMIT TRAN 
END
GO

CREATE or ALTER PROCEDURE dbo.CustomerOrdersCount
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@CustomerID INT,
			@StartDate date,
			@EndDate date,
			@xml XML; 
	
	BEGIN TRAN; 

	--от инициатора
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueReport; 

	SET @xml = CAST(@Message AS XML);

	SELECT
	@CustomerID = a.item.value('@CustomerID','INT'),
	@StartDate = a.item.value('@StartDate','DATE'),
	@EndDate = a.item.value('@EndDate','DATE')
	FROM @xml.nodes('/RequestMessage/row') as a(item);

	if @CustomerID is not null
	begin
		insert into dbo.ReportCustomersOrders(CustomerID, OrderCOUNTS, StartDate,EndDate)
		select
		@CustomerID, 
		COUNT(distinct a.OrderID), 
		@StartDate, @EndDate
		from	Sales.Invoices as a
		where	a.CustomerID = @CustomerID
				and a.InvoiceDate between @StartDate and @EndDate
	end

	SELECT @Message AS ReceivedRequestMessage, @MessageType as MessageType; 
	
	-- Confirm and Send a reply
	IF @MessageType=N'ReportRequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReportReplyMessage>Message receive, ok</ReportReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[ReportReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; 

	COMMIT TRAN;
END

--Сообщения инициатореа
CREATE or ALTER PROCEDURE  dbo.ConfirmCustomerOrdersCount
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueReport; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; 

	COMMIT TRAN; 
END

ALTER QUEUE [dbo].InitiatorQueueReport WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = OFF ,
        PROCEDURE_NAME = dbo.ConfirmCustomerOrdersCount, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER 
QUEUE [dbo].TargetQueueReport WITH STATUS = ON , RETENTION = OFF ,
POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = OFF ,
        PROCEDURE_NAME = dbo.CustomerOrdersCount, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO

SELECT *
FROM dbo.ReportCustomersOrders

--Send message
EXEC dbo.ReportParams 
	@CustomerID = 832, 
	@StartDate = '2013-01-01',
	@EndDate = '2013-01-05';

SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueReport;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueReport;

--Target
EXEC dbo.CustomerOrdersCount

--Initiator
EXEC dbo.ConfirmCustomerOrdersCount

select * from dbo.ReportCustomersOrders