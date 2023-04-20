/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
;with a as (
	select c.CustomerID,a.InvoiceDate,  c.CustomerName, sum(b.ExtendedPrice) as ExtendedPrice
	from sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join sales.Customers as c on c.CustomerID = a.CustomerID
	where a.InvoiceDate >= '20150101'
	group by  c.CustomerID,a.InvoiceDate,  c.CustomerName, a.InvoiceDate
)

select 
	a.InvoiceDate
	,a.CustomerName
	,a.ExtendedPrice
	,(select sum(bb.ExtendedPrice) from Sales.Invoices as aa 
	join sales.InvoiceLines as bb on bb.InvoiceID = aa.InvoiceID
	where month(aa.InvoiceDate) <= month(a.InvoiceDate)
	and aa.InvoiceDate >= '20150101')
from a as a 
order by a.InvoiceDate,a.CustomerName

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
/*напишите здесь свое решение*/

;with a as (
	select a.InvoiceDate,  c.CustomerName, sum(b.ExtendedPrice) as ExtendedPrice
	from sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join sales.Customers as c on c.CustomerID = a.CustomerID
	where a.InvoiceDate >= '20150101'
	group by  a.InvoiceDate,  c.CustomerName, a.InvoiceDate)
select 
* 
,sum(a.ExtendedPrice) over (order by month(a.InvoiceDate))
from a as a 
order by a.InvoiceDate, a.CustomerName

--Вариант с оконными функциями отрабатывает в разы быстрее, меньше чтений

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
;with a as (
	select 
	month(a.InvoiceDate) as mm, 
	b.StockItemID, 
	count(*) as counts 
	from sales.Invoices as a
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	where YEAR(a.InvoiceDate) = '2016'
	group by month(a.InvoiceDate), b.StockItemID) 

select 
mm, si.StockItemName, RN
from (
	select 
	*, ROW_NUMBER() over (partition by mm order by counts desc) as RN
	from a as a
) as result
join Warehouse.StockItems as si on si.StockItemID = result.StockItemID
where RN <=2
order by mm, RN
/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select 
	StockItemID,
	StockItemName,
	Brand,
	UnitPrice,
	left(StockItemName,1),
	ROW_NUMBER() over (partition by left(StockItemName,1) order by StockItemName),
	count(*) over (),
	count(*) over (partition by left(StockItemName,1)),
	lead(StockItemID) over (order by StockItemName),
	lag(StockItemID) over (order by StockItemName),
	lag(StockItemName,2,'No items') over (order by StockItemName),
	ntile(30) over (order by TypicalWeightPerUnit)
from 
Warehouse.StockItems
order by 2
/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
;with cte as (
select 
a.InvoiceID, a.SalespersonPersonID ,a.InvoiceDate,
ROW_NUMBER() over (partition by a.SalespersonPersonID order by a.InvoiceID desc) as rn
from Sales.Invoices as a 
)

select 
a.SalespersonPersonID, 
b.FullName,
a.CustomerID,
c.CustomerName,
a.InvoiceDate,
il.ExtendedPrice
from Sales.Invoices as a 
join (select sum(ExtendedPrice) as ExtendedPrice, InvoiceID from Sales.InvoiceLines as il group by InvoiceID) as il on il.InvoiceID = a.InvoiceID
join cte as cte on cte.InvoiceID = a.InvoiceID and rn = 1
join Application.People as b on b.PersonID = a.SalespersonPersonID
join sales.Customers as c on c.CustomerID = a.CustomerID
order by 2,5


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;with cte_a as (
select distinct 
	a.CustomerID,
	d.CustomerName,
	b.StockItemID,
	c.UnitPrice
from 
	sales.Invoices as a 
	join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
	join Warehouse.StockItems as c on c.StockItemID = b.StockItemID
	join sales.Customers as d on d.CustomerID =a.CustomerID)
,cte_top2 as (
select *, ROW_NUMBER() over (partition by CustomerID order by UnitPrice desc) as rn
from cte_a
)

select 
c.CustomerID,
c.CustomerName,
c.StockItemID,
c.UnitPrice,
a.InvoiceDate
from 
sales.Invoices as a 
join sales.InvoiceLines as b on b.InvoiceID = a.InvoiceID
join cte_top2 as c on c.CustomerID = a.CustomerID and c.StockItemID = b.StockItemID and c.rn <=2


--Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 