/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	[Год продажи] = year(a.InvoiceDate),
	[Месяц продажи] = month(a.InvoiceDate),
	[Средняя цена за месяц по всем товарам] = avg(b.UnitPrice),
	[Общая сумма продаж за месяц] = sum(b.UnitPrice*b.Quantity)
from 
	sales.Invoices as a
	join sales.InvoiceLines as b on a.InvoiceID = b.InvoiceID
group by 
	year(a.InvoiceDate),
	month(a.InvoiceDate)
order by 1,2

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
Сортировка по году и месяцу.

*/

select 
	[Год продажи] = year(a.InvoiceDate),
	[Месяц продажи] = month(a.InvoiceDate),
	[Общая сумма продаж] = sum(b.UnitPrice*b.Quantity)
from 
	sales.Invoices as a
	join sales.InvoiceLines as b on a.InvoiceID = b.InvoiceID
group by 
	year(a.InvoiceDate),
	month(a.InvoiceDate)
having 
	sum(b.UnitPrice*b.Quantity) > 4600000
order by 1,2
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select 
	[Год продажи] = year(a.InvoiceDate),
	[Месяц продажи] = month(a.InvoiceDate),
	[Наименование товара] = c.StockItemName,
	[Общая сумма продаж] = sum(b.UnitPrice*b.Quantity),
	[Дата первой продажи] = min(a.InvoiceDate),
	[Количество проданного] = sum(b.Quantity)
from 
	sales.Invoices as a
	join sales.InvoiceLines as b on a.InvoiceID = b.InvoiceID
	join Warehouse.StockItems as c on c.StockItemID = b.StockItemID
group by 
	year(a.InvoiceDate),
	month(a.InvoiceDate),
	c.StockItemName

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
4. Написать второй запрос ("Отобразить все месяцы, где общая сумма продаж превысила 4 600 000") 
за период 2015 год так, чтобы месяц, в котором сумма продаж была меньше указанной суммы также отображался в результатах,
но в качестве суммы продаж было бы '-'.
Сортировка по году и месяцу.

Пример результата:
-----+-------+------------
Year | Month | SalesTotal
-----+-------+------------
2015 | 1     | -
2015 | 2     | -
2015 | 3     | -
2015 | 4     | 5073264.75
2015 | 5     | -
2015 | 6     | -
2015 | 7     | 5155672.00
2015 | 8     | -
2015 | 9     | 4662600.00
2015 | 10    | -
2015 | 11    | -
2015 | 12    | -

*/
;with a as (
select 
	[Год продажи] = year(a.InvoiceDate),
	[Месяц продажи] = month(a.InvoiceDate),
	[Общая сумма продаж] = sum(b.UnitPrice*b.Quantity)
from 
	sales.Invoices as a
	join sales.InvoiceLines as b on a.InvoiceID = b.InvoiceID
group by 
	year(a.InvoiceDate),
	month(a.InvoiceDate)
having 
	sum(b.UnitPrice*b.Quantity) > 4600000
), b as (
select * from (values (2015,1),(2015,2),(2015,3),(2015,4),(2015,5),(2015,6),(2015,7),(2015,8),(2015,9),(2015,10),(2015,11),(2015,12)) 
	as datelist([year],[month])
) 
select 
b.year,b.month,isnull(cast(a.[Общая сумма продаж] as varchar), '-') as SalesTotal
from b
left join a on a.[Год продажи] = b.year and a.[Месяц продажи] = b.month
order by 1,2
