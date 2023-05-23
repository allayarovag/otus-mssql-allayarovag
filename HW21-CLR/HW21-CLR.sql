--Включаем, необходимо разрешить использование CLR в SQL Server.
exec sp_configure 'show advanced options', 1
go
reconfigure
go
exec sp_configure 'clr enabled', 1
go
exec sp_configure 'clr strict security',0
go
reconfigure
go

alter database WideWorldImporters set trustworthy on
use WideWorldImporters

CREATE ASSEMBLY CLR_demo_one
FROM 'C:\Git\Clr_demo1\bin\Debug\Clr_demo1.dll'
with permission_set = safe
go

--select * from sys.assemblies

--Функция вывода в столбец, значений строки через разделитель

CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME CLR_demo_one.UserDefinedFunctions.SplitString

select * from  dbo.SplitStringCLR ('1,2,3,4,5,8.6.9.7','.')
