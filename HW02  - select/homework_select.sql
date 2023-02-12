/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select a.StockItemID, StockItemName from Warehouse.StockItems as a  
where a.StockItemName like '%urgent%' or a.StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select distinct a.SupplierID, a.SupplierName 
from  Purchasing.Suppliers as a 
except
select 
distinct a.SupplierID, a.SupplierName
from Purchasing.Suppliers as a 
left join Purchasing.PurchaseOrders as b on b.SupplierID = a.SupplierID
where b.PurchaseOrderID is not null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select 
[id заказа] = a.OrderID, 
[Дата] = FORMAT(a.OrderDate, 'dd.MM.yyyy'), 
[Месяц] = datename(MONTH,a.OrderDate),
[Квартал] = datepart(QUARTER,a.OrderDate),
[Треть] = case 
	when datepart(MONTH,a.orderDate) between 1 and 4 then 1
	when datepart(MONTH,a.orderDate) between 5 and 8 then 2
	else 3
end,
[Покупатель] = c.CustomerName

from sales.Orders as a 
join sales.OrderLines as b on b.OrderID = a.OrderID
join sales.Customers as c on c.CustomerID = a.CustomerID
where (b.UnitPrice > 100 or b.Quantity > 20) and b.PickingCompletedWhen is not null
order by [Квартал],[Треть],[Дата]
offset 1000 rows fetch first 100 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select 
b.DeliveryMethodName, a.ExpectedDeliveryDate, c.SupplierName, d.FullName
from
Purchasing.PurchaseOrders as a 
join Purchasing.Suppliers as c on c.SupplierID = a.SupplierID 
join [Application].DeliveryMethods as b on b.DeliveryMethodID = a.DeliveryMethodID
join [Application].People as d on d.PersonID = a.ContactPersonID
where 
b.DeliveryMethodName in ('Air Freight','Refrigerated Air Freight')
and DATEPART(MONTH,a.ExpectedDeliveryDate) = 1 
and DATEPART(YEAR,a.ExpectedDeliveryDate) = 2013
and IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 
b.CustomerName, c.FullName
from sales.Orders as a 
join sales.Customers as b on b.CustomerID = a.CustomerID
join Application.People as c on c.PersonID = a.SalespersonPersonID
order by a.OrderDate desc
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct d.CustomerID,d.CustomerName, d.PhoneNumber  
from sales.Orders as a
join Sales.OrderLines as b on b.OrderID = a.OrderID
join Warehouse.StockItems as c on c.StockItemID = b.StockItemID
join sales.Customers as d on d.CustomerID = a.CustomerID
where c.StockItemName = 'Chocolate frogs 250g'