create table Categories
(
    CategoryId   int identity
        primary key,
    CategoryName varchar(64) not null
        constraint UniqueCategoryName
            unique,
    Description  varchar(256)
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Categories to admin
go

create table ConditionOrders
(
    WK smallint,
    WZ smallint,
    Z1 smallint,
    K1 smallint,
    K2 smallint,
    Z3 smallint,
    K4 smallint
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on ConditionOrders to admin
go

create table Customers
(
    CustomerId  int identity
        primary key,
    Email       varchar(64)
        constraint ProperEmail
            check ([Email] like '%@%.%'),
    Phone       varchar(64)
        constraint ProperPhoneNumber
            check ([Phone] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' OR
                   [Phone] like '+[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    City        varchar(64) not null,
    Street      varchar(64) not null,
    HouseNumber varchar(32) not null,
    Country     varchar(64) not null
)
go

create table Companies
(
    CustomerId  int         not null
        primary key
        references Customers,
    CompanyName varchar(64) not null,
    NIP         varchar(10) not null
        constraint UniqueNip
            unique
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Companies to admin
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Customers to admin
go

create table Discount
(
    DiscountType int  not null
        primary key,
    Value        real not null
        constraint ProperDiscount
            check ([Value] >= 0 AND [Value] <= 1)
)
go

create table [Discount Details]
(
    DiscountId   int not null
        primary key,
    CustomerId   int not null
        references Customers,
    DiscountType int not null
        references Discount,
    Active       bit not null,
    ExpiredDate  datetime
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on [Discount Details] to admin
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Discount to admin
go

create table [Individual Customers]
(
    CustomerId int         not null
        primary key
        references Customers,
    FirstName  varchar(64) not null,
    LastName   varchar(64) not null
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on [Individual Customers] to admin
go

create table Menu
(
    MenuId      int identity
        primary key,
    StartedDate datetime not null,
    EndedDate   datetime not null,
    Valid       bit      not null,
    Accepted    bit      not null,
    constraint ProperDate
        check ([StartedDate] < [EndedDate])
)
go

create index DataRangeOfMenu
    on Menu (StartedDate, EndedDate)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Menu to admin
go

create table Products
(
    ProductId   int identity
        primary key,
    CategoryId  int         not null
        references Categories,
    ProductName varchar(64) not null
        constraint UniqueProductName
            unique,
    Description varchar(256)
)
go

create table [Menu Details]
(
    MenuId         int   not null
        references Menu,
    ProductID      int   not null
        references Products,
    PriceOfProduct money not null
        constraint positivePrice
            check ([PriceOFProduct] > 0),
    primary key (MenuId, ProductID)
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on [Menu Details] to admin
go

grant references, select, take ownership, update, view definition on Products to admin
go

create table Receipt
(
    ReceiptID int identity
        primary key,
    IssueDate date not null
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Receipt to admin
go

create table Reservation
(
    ReservationId    int identity
        primary key,
    StartReservation datetime not null,
    EndReservation   datetime not null,
    Accepted         bit      not null,
    constraint ProperDateReservation
        check ([StartReservation] < [EndReservation])
)
go

create table [Names Reservation]
(
    ReservationId int         not null
        references Reservation,
    Names         varchar(64) not null,
    constraint [PK__Names Re__B7EE5F246467060E]
        primary key (ReservationId, Names)
)
go

grant references, select, take ownership, update, view definition on [Names Reservation] to admin
go

create table Orders
(
    OrderId           int identity
        primary key,
    CustomerId        int      not null
        references Customers,
    OrderDate         datetime not null,
    StatusReservation bit      not null,
    RealisationDate   datetime,
    PaidOrder         bit      not null,
    ReservationId     int
        references Reservation,
    ReceiptID         int
        references Receipt,
    DiscountID        int,
    constraint UniqueOrderInfo
        unique (ReservationId, CustomerId, OrderDate)
)
go

create table [Orders Details]
(
    OrderId   int      not null
        references Orders,
    ProductId int      not null
        references Products,
    Quantity  smallint not null,
    primary key (OrderId, ProductId)
)
go

grant references, select, take ownership, update, view definition on [Orders Details] to admin
go

grant references, select, take ownership, update, view definition on Orders to admin
go

create table Payments
(
    PaymentId   int identity
        primary key,
    OrderId     int      not null
        references Orders,
    DatePayment datetime not null,
    MoneyPaid   money    not null
)
go

grant references, select, take ownership, update, view definition on Payments to admin
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on Reservation to admin
go

create table Tables
(
    TableId int     not null
        primary key,
    Seats   tinyint not null
        constraint ProperSeatsNumber
            check ([Seats] > 0)
)
go

create table [Reservation Details]
(
    ReservationId int identity
        references Reservation,
    TableID       int not null
        references Tables,
    primary key (ReservationId, TableID)
)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on [Reservation Details] to admin
go

grant references, select, take ownership, update, view definition on Tables to admin
go

create table sysdiagrams
(
    name         sysname not null,
    principal_id int     not null,
    diagram_id   int identity
        primary key,
    version      int,
    definition   varbinary(max),
    constraint UK_principal_name
        unique (principal_id, name)
)
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'TABLE', 'sysdiagrams'
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on sysdiagrams to admin
go

create view ClientStats as
select c.CustomerId,
       c.Country,
       c.City,
       c.Street,
       count(o.OrderId) as [amount of orders],
       isnull(c.Email, 'BRAK') as email,
       isnull(c.Phone, 'BRAK') as phone,
       isnull(sum(ov.value), 0) as [sum of orders]
from Customers c
inner join orders o
    on c.CustomerId = o.CustomerId
left join orderValue ov
    on ov.OrderId = o.OrderId
group by c.CustomerId, c.Country, c.City, c.Street,
         isnull(c.Email, 'BRAK'), isnull(c.Phone, 'BRAK')
go

grant references, select, take ownership, update, view definition on ClientStats to admin
go

CREATE VIEW CurrentMenu
AS
SELECT ProductName AS Dish, PriceOfProduct [Regular Price] FROM Menu m
JOIN [Menu Details] md ON md.MenuId = m.MenuId AND GETDATE() BETWEEN m.StartedDate AND m.EndedDate
JOIN Products p ON p.ProductId = md.ProductID
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on CurrentMenu to admin
go

grant select on CurrentMenu to customer
go

grant select on CurrentMenu to employee
go

create view DiscountInfoMonthly
as
SELECT YEAR(OrderDate) year, MONTH(OrderDate) month, count(DiscountId) 'amount of discounts'
from Orders
group by YEAR(OrderDate), MONTH(OrderDate)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on DiscountInfoMonthly to admin
go

create view DiscountInfoWeekly
as
SELECT YEAR(OrderDate) year, datepart(week , OrderDate) weak, count(DiscountId) 'amount of discounts'
from Orders
group by YEAR(OrderDate), datepart(week , OrderDate)
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on DiscountInfoWeekly to admin
go

create view MealsInfo as
select p.ProductName ,c.CategoryName,
       isnull(c.Description, 'BRAK OPISU') as categoryDescription,
       isnull(p.Description, 'BRAK OPISU') as productsDescription
from Products p
inner join Categories c
    on p.CategoryId = c.CategoryId
go

grant references, select, take ownership, update, view definition on MealsInfo to admin
go

create view MealsSoldInfo as
select p.ProductName, count(od.OrderId) as [amount of products]
from Products p
left join [Orders Details] od
    on p.ProductId = od.ProductId
group by p.ProductName
go

grant references, select, take ownership, update, view definition on MealsSoldInfo to admin
go

create view MealsSoldMonthly as
select year(o.OrderDate) as year,
       month(o.OrderDate) as month,
       p.ProductName,
       isnull(count(p.ProductName), 0) as [Amount Of Sold]
from Products p
join [Orders Details] od
    on p.ProductId = od.ProductId
join Orders o
    on od.OrderId = o.OrderId
group by p.ProductName, month(o.OrderDate), year(o.OrderDate)
go

grant references, select, take ownership, update, view definition on MealsSoldMonthly to admin
go

CREATE view MealsSoldWeekly as
select year(o.OrderDate) as year,
       datepart(week, o.OrderDate) as week,
       p.ProductName,
       isnull(count(p.ProductName), 0) as [Amount Of Sold]
from Products p
inner join [Orders Details] od
    on p.ProductId = od.ProductId
inner join Orders o
    on od.OrderId = o.OrderId
group by year(o.OrderDate), datepart(week, o.OrderDate), p.ProductName
go

grant references, select, take ownership, update, view definition on MealsSoldWeekly to admin
go

CREATE VIEW MenuStats
AS
SELECT ProductName AS Dish, COUNT(MenuId) AS [times on menu], AVG(PriceOfProduct) [AVG Price], MAX(PriceOfProduct) [MAX Price], MIN(PriceOfProduct) [MIN Price] 
FROM Products p
LEFT JOIN [Menu Details] md ON md.ProductID = p.ProductId
GROUP BY ProductName
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on MenuStats to admin
go

create view OrderInfo
as
SELECT OrderId, (select SUM(OD.Quantity * PriceOfProduct)
                 from [Orders Details] OD
                 inner join Products P on P.ProductId = OD.ProductId
                 inner join [Menu Details] MD on P.ProductId = MD.ProductID
                 where OD.OrderId = O.OrderId
                 GROUP BY OD.OrderId) as 'order value',
                CustomerId,
                OrderDate,
                PaidOrder

from Orders O
go

grant references, select, take ownership, update, view definition on OrderInfo to admin
go

grant select on OrderInfo to employee
go

CREATE VIEW OrderValue
AS
SELECT o.OrderId, sum(Quantity*PriceOfProduct*(1-IsNull(d.value,0))) AS value FROM Orders o
JOIN [Orders Details] od ON o.OrderId = od.OrderId
JOIN Menu m ON o.OrderDate BETWEEN m.StartedDate AND m.EndedDate
JOIN [Menu Details] md on m.MenuId = md.MenuId AND md.ProductID = od.ProductId
LEFT JOIN [Discount Details] dd ON dd.DiscountId = o.DiscountID
LEFT JOIN Discount d ON d.DiscountType = dd.DiscountType
GROUP BY o.OrderId
go

grant references, select, take ownership, update, view definition on OrderValue to admin
go

grant select on OrderValue to employee
go

CREATE VIEW OrdersStatsMonthly
AS
WITH 
	mindate AS
		(SELECT TOP 1 Orderdate FROM Orders ORDER BY OrderDate),
	maxdate AS
		(SELECT TOP 1 Orderdate FROM Orders ORDER BY OrderDate DESC),
	rm(dt)  AS (
		SELECT (SELECT * FROM mindate) as dt
		UNION all
		SELECT dateadd(mm,1,dt) FROM rm WHERE dt<(SELECT * FROM maxdate)
		),
	orderValue AS(
		SELECT o.OrderId, sum(Quantity*PriceOfProduct*(1-IsNull(d.value,0))) AS value FROM Orders o
		JOIN [Orders Details] od ON o.OrderId = od.OrderId
		JOIN Menu m ON o.OrderDate BETWEEN m.StartedDate AND m.EndedDate
		JOIN [Menu Details] md on m.MenuId = md.MenuId AND md.ProductID = od.ProductId
		LEFT JOIN [Discount Details] dd ON dd.DiscountId = o.DiscountID
		LEFT JOIN Discount d ON d.DiscountType = dd.DiscountType
		GROUP BY o.OrderId
		),
	t AS 
		(SELECT  year(orderdate) AS year, month(orderdate) AS month, count(*) AS cnt, sum(ov.value) AS value
		FROM Orders o
		JOIN orderValue ov ON o.OrderId = ov.OrderId
		--where year(orderdate) BETWEEN (SELECT * FROM mindate) AND (SELECT * FROM maxdate)
		group by year(orderdate), month(orderdate)
		)
SELECT  year(dt) AS ROK, month(dt) AS MIESIAC , ISNULL(cnt,0) AS ILOSC_ZAMOWIEN,ISNULL(value,0) AS WARTOSC
FROM rm
LEFT JOIN t ON t.year = year(dt) AND t.month = month(dt);
go

grant references, select, take ownership, update, view definition on OrdersStatsMonthly to admin
go

CREATE VIEW OrdersStatsWeekly
AS
WITH 
	mindate AS
		(SELECT TOP 1 Orderdate FROM Orders ORDER BY OrderDate),
	maxdate AS
		(SELECT TOP 1 Orderdate FROM Orders ORDER BY OrderDate DESC),
	rm(dt)  AS (
		SELECT (SELECT * FROM mindate) as dt
		UNION all
		SELECT dateadd(ww,1,dt) FROM rm WHERE dt<(SELECT * FROM maxdate)
		),
	orderValue AS(
		SELECT o.OrderId, sum(Quantity*PriceOfProduct*(1-IsNull(d.value,0))) AS value FROM Orders o
		JOIN [Orders Details] od ON o.OrderId = od.OrderId
		JOIN Menu m ON o.OrderDate BETWEEN m.StartedDate AND m.EndedDate
		JOIN [Menu Details] md on m.MenuId = md.MenuId AND md.ProductID = od.ProductId
		LEFT JOIN [Discount Details] dd ON dd.DiscountId = o.DiscountID
		LEFT JOIN Discount d ON d.DiscountType = dd.DiscountType
		GROUP BY o.OrderId
		),
	t AS 
		(SELECT  YEAR(OrderDate) year, DATEPART(ww,orderDate) week, count(*) AS cnt, sum(ov.value) AS value
		FROM Orders o
		JOIN orderValue ov ON o.OrderId = ov.OrderId
		--where year(orderdate) BETWEEN (SELECT * FROM mindate) AND (SELECT * FROM maxdate)
		group by year(orderdate), DATEPART(ww,orderDate)
		)
SELECT  year(dt) AS ROK, DATEPART(ww,dt) AS TYDZIEN , ISNULL(cnt,0) AS ILOSC_ZAMOWIEN ,ISNULL(value,0) AS WARTOSC_ZAMOWIEN
FROM rm
LEFT JOIN t ON t.year = year(dt) AND t.week = DATEPART(ww,dt);
go

grant references, select, take ownership, update, view definition on OrdersStatsWeekly to admin
go

CREATE VIEW OrdersToPay
AS
WITH 
orderValue AS(
		SELECT o.OrderId, sum(Quantity*PriceOfProduct*(1-IsNull(d.value,0))) AS value FROM Orders o
		JOIN [Orders Details] od ON o.OrderId = od.OrderId
		JOIN Menu m ON o.OrderDate BETWEEN m.StartedDate AND m.EndedDate
		JOIN [Menu Details] md on m.MenuId = md.MenuId AND md.ProductID = od.ProductId
		LEFT JOIN [Discount Details] dd ON dd.DiscountId = o.DiscountID
		LEFT JOIN Discount d ON d.DiscountType = dd.DiscountType
		GROUP BY o.OrderId
		)
SELECT o.OrderId, CustomerID, OrderDate, (ISNULL(sum(p.MoneyPaid),0) - ov.value) balance FROM Orders o
LEFT JOIN Payments p ON p.OrderId = o.OrderId
JOIN orderValue ov on ov.OrderId = o.OrderId
GROUP BY  o.OrderId, CustomerID, OrderDate,ov.value
HAVING  (ISNULL(sum(p.MoneyPaid),0) - ov.value)<>0;
go

grant references, select, take ownership, update, view definition on OrdersToPay to admin
go

grant select on OrdersToPay to employee
go

create view OwingClients
as
SELECT CustomerId, (isnull(Sum(MoneyPaid),0) - sum(OV.value)) as debt
from Orders O
left join Payments P2 on O.OrderId = P2.OrderId
inner join OrderValue OV on O.OrderId = OV.OrderId
where PaidOrder = 0
GROUP BY CustomerId
go

grant references, select, take ownership, update, view definition on OwingClients to admin
go

grant select on OwingClients to employee
go

create view PendingReservation as
select r.ReservationId, r.StartReservation, r.EndReservation, o.CustomerId, o.OrderId, 'In processing' as [accepted?]
from Reservation r
inner join Orders o
    on r.ReservationId = o.ReservationId
where r.Accepted = 0
go

grant references, select, take ownership, update, view definition on PendingReservation to admin
go

grant select on PendingReservation to employee
go

create view ReservationInfo as
select r.ReservationId, r.StartReservation, r.EndReservation, count(rd.TableID) as [amount of tables]
from Reservation r
inner join [Reservation Details] rd
    on r.ReservationId = rd.ReservationId
where r.Accepted = 1
group by r.ReservationId, r.StartReservation, r.EndReservation
go

grant references, select, take ownership, update, view definition on ReservationInfo to admin
go

create view TablesMonthly as
select year(r.StartReservation) as year,
       month(r.StartReservation) as month,
       t.TableId,
       t.Seats as [size of table],
       count(rd.TableID) as [how many times reservated]
from Tables t
inner join [Reservation Details] rd
    on t.TableId = rd.TableID
inner join Reservation r
    on rd.ReservationId = r.ReservationId
group by year(r.StartReservation), month(r.StartReservation), t.TableId, t.Seats
go

grant references, select, take ownership, update, view definition on TablesMonthly to admin
go

create view TablesWeekly as
select year(r.StartReservation) as year,
       datepart(week, r.StartReservation) as week,
       t.TableId,
       t.Seats as [size of table],
       count(rd.TableID) as [how many times reservated]
from Tables t
inner join [Reservation Details] rd
    on t.TableId = rd.TableID
inner join Reservation r
    on rd.ReservationId = r.ReservationId
group by year(r.StartReservation),datepart(week, r.StartReservation), t.TableId, t.Seats
go

grant references, select, take ownership, update, view definition on TablesWeekly to admin
go

CREATE PROCEDURE AddCustomer
@Email varchar(64) = null,
@Phone varchar(64) = null,
@City varchar(64),
@Street varchar(64),
@HouseNumber varchar(32),
@Country varchar(64),
@ClientType varchar(1),
@CompanyName varchar(64) = null,
@NIP varchar(10) = null,
@FirstName varchar(64) = null,
@LastName varchar(64) = null
as
begin
    set nocount on
    begin try
        if exists(
            select * from Companies
            where CompanyName = @CompanyName
            )
        begin
                 ; throw 60000, N'Dana firma istnieje już w bazie', 1
            end
        if exists(
            select * from Companies
            where NIP = @NIP
            )
        begin
                 ; throw 60000, N'Dany numer NIP istnieje już w bazie', 1
            end

        declare @CustomerID int
        insert into Customers(Email, Phone, City, Street, HouseNumber, Country)
        values (@Email, @Phone, @City, @Street, @HouseNumber, @Country)
        set @CustomerID = scope_identity()
        if @ClientType = 'C'
            insert into Companies(CustomerId, CompanyName, NIP)
            values (@CustomerId, @CompanyName, @NIP)
        if @ClientType = 'I'
            insert into [Individual Customers](CustomerId, FirstName, LastName)
            values (@CustomerId, @FirstName, @LastName)
    end try
    begin catch
        declare @msg nvarchar(2000) = N'Błąd dodawania klienta do bazy: ' + ERROR_MESSAGE();
        THROW 60000, @msg, 1;
    end catch
end
go

grant alter, control, execute, take ownership, view definition on AddCustomer to admin
go

grant execute on AddCustomer to employee
go

CREATE procedure AddDiscount(
    @DiscountId int,
    @CustomerId int,
    @Active bit = 1
)
as
    begin
        set nocount on
        declare @DiscountType as int
        set @DiscountType = 0
        declare @Z1 as int
                set @Z1 = (select Z1 from ConditionOrders)
        declare @K1 as int
                set @K1 = (select K1 from ConditionOrders)
        declare @K2 as int
                set @K2 = (select K2 from ConditionOrders)
        declare @K4 as int
                set @K4 = (select K4 from ConditionOrders)
        declare @Z3 as int
                set @Z3 = (select Z3 from ConditionOrders)


        if ( 1 not in (select DiscountType
                   from [Discount Details]
                   where CustomerId = @CustomerId)
            )
            begin
                if (select count(O.OrderId)
                    from Orders O
                    join OrderValue V on O.OrderId = V.OrderId
                    where CustomerId = @CustomerId
                      and value > @K1 ) >= @Z1
                    begin
                        set @DiscountType = 1
                    end
            end
        else
            begin
                if ( 2 not in (select DiscountType
                       from [Discount Details]
                       where CustomerId = @CustomerId)
                )
                begin
                    if (select sum(value)
                        from OrderValue OV
                        join Orders O on OV.OrderId = O.OrderId
                        where CustomerId = @CustomerId) >= @K2
                        begin
                            set @DiscountId = 2
                        end
                end
            end

        declare @OldPayment as int
        declare @newPayments as int

        set @newPayments = (select sum(MoneyPaid)
                            from Payments)

        set @OldPayment = (@newPayments - (select top 1 MoneyPaid
                                           from Payments
                                           order by DatePayment desc ))

        if ((@newPayments / @K4)- (@OldPayment / @K4) > 1)
            begin
                if (select sum(value)
                    from OrderValue OV
                    join Orders O on OV.OrderId = O.OrderId
                    where CustomerId = @CustomerId) >= @K4
                    begin
                        set @DiscountId = 4
                    end
            end

        if (select count(OrderId)
                from Orders
                where CustomerId = @CustomerId) % @Z3= 0 and (select count(OrderId)
                from Orders
                where CustomerId = @CustomerId) > 0
                begin
                    set @DiscountType = 3
                end

        if (@DiscountType > 0 )
            begin
                insert into [Discount Details] (DiscountId, CustomerId, DiscountType, Active)
                values (@DiscountId, @CustomerId, @DiscountType, @Active)
            end
    end
go

grant alter, control, execute, take ownership, view definition on AddDiscount to admin
go

grant execute on AddDiscount to employee
go

CREATE PROCEDURE AddDiscountToOrder(
	@DiscountID AS INT,
	@OrderID AS INT
	)
AS 
BEGIN
	DECLARE @CustomerID AS INTEGER

	SET @CustomerID = (SELECT CustomerID FROM ORders WHERE ORderID = @OrderID)
	IF @DiscountID IN (SELECT DiscountId FROM [Discount Details] dd
						JOIN Customers c ON c.CustomerId = dd.CustomerId)
	BEGIN
		IF (SELECT Active FROM [Discount Details]) = 1
		BEGIN
			Update Orders
			SET DiscountID = @DiscountID
			WHERE OrderId = @OrderID
		END
	END
END
go

CREATE procedure AddOrder(
@CustomerId int,
@PaidOrder bit  = 0,
@RealisationDate datetime= null,
@StatusReservation bit = 0,
@DiscountID int = null,
@OrderDate datetime,
@ReservationID int = null,
@ReceiptID int = null
)
as
    begin
        set nocount on
        INSERT INTO Orders(CustomerId, OrderDate, StatusReservation, RealisationDate, PaidOrder, ReservationId, ReceiptID, DiscountID)
        VALUES (@CustomerId, @OrderDate, @StatusReservation,@RealisationDate, @PaidOrder,@ReservationID,@ReceiptID,@DiscountID)
    end
go

grant alter, control, execute, take ownership, view definition on AddOrder to admin
go

grant execute on AddOrder to customer
go

grant execute on AddOrder to employee
go

CREATE PROCEDURE AddToMenu(
	@menuID AS INTEGER
	,@productID AS INTEGER
	,@price AS MONEY
)
AS
BEGIN
	INSERT INTO [Menu Details](MenuId,ProductID,PriceOfProduct) VALUES (@menuID,@productID,@price)

	DECLARE @valid AS BIT
	EXEC @valid =  dbo.MenuCorrect @id = @menuID
    IF @valid = 1
	BEGIN
		UPDATE Menu
			SET Valid = 1
			WHERE Menu.MenuId = @menuID
	END
END
go

grant alter, control, execute, take ownership, view definition on AddToMenu to admin
go

CREATE PROCEDURE AddToOrder(
	@OrderID AS INT
	,@ProductID AS INT
	,@Quantity AS SMALLINT
	)
AS
BEGIN

	IF @ProductID IN 
		(SELECT ProductID FROM [Menu Details] md
		JOIN Menu m ON m.MenuId = md.MenuId
		WHERE (SELECT OrderDate FROM Orders WHERE OrderId = @OrderID) BETWEEN m.StartedDate AND m.EndedDate)
	BEGIN
		
		IF @ProductID IN (SELECT ProductID FROM Products p
							JOIN Categories c ON c.CategoryId = p.CategoryId
							WHERE CategoryName = 'Egzotyczne')
			BEGIN 
			DECLARE @neededspace AS INT
			DECLARE @realisationDate AS DATETIME
			SET @realisationDate = (SELECT RealisationDate FROM Orders WHERE OrderID = @OrderID)
			SET @neededspace =  
				CASE 	
					WHEN datename(dw,dateadd(day,-1,@realisationDate))='Monday' THEN 1
					WHEN datename(dw,dateadd(day,-2,@realisationDate))='Monday' THEN 2
					WHEN datename(dw,dateadd(day,-3,@realisationDate))='Monday' THEN 3
					WHEN datename(dw,dateadd(day,-4,@realisationDate))='Monday' THEN 4
					WHEN datename(dw,dateadd(day,-5,@realisationDate))='Monday' THEN 5
					WHEN datename(dw,dateadd(day,-6,@realisationDate))='Monday' THEN 6
					WHEN datename(dw,dateadd(day,-7,@realisationDate))='Monday' THEN 7
				END
			IF @realisationDate - (SELECT Orderdate FROM Orders WHERE OrderID = @OrderID) >= @neededspace
			BEGIN 
				INSERT INTO [Orders Details](OrderId,ProductId,Quantity) VALUES (@OrderID,@ProductID,@Quantity)
			END
		END
			ELSE
			BEGIN
				INSERT INTO [Orders Details](OrderId,ProductId,Quantity) VALUES (@OrderID,@ProductID,@Quantity)
			END
	END
END
go

grant alter, control, execute, take ownership, view definition on AddToOrder to admin
go

grant execute on AddToOrder to customer
go

grant execute on AddToOrder to employee
go

create procedure AddToReservation(

@StartReservation datetime,
@EndReservation datetime,
@Accepted bit = 0,
@OrderId int
)
as
    begin
        set nocount on
        declare @ResevationId int;

        insert into Reservation(StartReservation, EndReservation, Accepted)
        VALUES (@StartReservation, @EndReservation, @Accepted)

        set  @ResevationId = SCOPE_IDENTITY()

        update Orders
        set ReservationId = @ResevationId
        where OrderId = @OrderId

    end
go

grant alter, control, execute, take ownership, view definition on AddToReservation to admin
go

grant execute on AddToReservation to customer
go

grant execute on AddToReservation to employee
go

CREATE FUNCTION AmountOfTakeaways()
	RETURNS INT
	AS
	BEGIN
		DECLARE @RESULT AS INT
		SET @result = (SELECT COUNT(OrderID) FROM Orders WHERE ReservationId IS NULL)
		RETURN @result
		
	END
go

grant alter, control, execute, references, take ownership, view definition on AmountOfTakeaways to admin
go

grant execute on AmountOfTakeaways to employee
go

CREATE PROCEDURE CheckForDisconts(
	@CustomerId AS INT
	)
AS 
BEGIN
declare @DiscountType as int
        declare @Z1 as int
                set @Z1 = (select Z1 from ConditionOrders)
        declare @K1 as int
                set @K1 = (select K1 from ConditionOrders)
        declare @K2 as int
                set @K2 = (select K2 from ConditionOrders)
        declare @K4 as int
                set @K4 = (select K4 from ConditionOrders)
        declare @Z3 as int
                set @Z3 = (select Z3 from ConditionOrders)
		DECLARE @Discount1 AS INT
		SET @Discount1 = 0
		DECLARE @Discount2 AS INT
		SET @Discount2 = 0
		DECLARE @Discount3 AS INT
		SET @Discount3 = 0
		DECLARE @Discount4 AS INT
		SET @Discount4 = 0

        if ( 1 not in (select DiscountType
                   from [Discount Details]
                   where CustomerId = @CustomerId)
            )
            if (select count(O.OrderId)
                from Orders O
                join OrderValue V on O.OrderId = V.OrderId
                where CustomerId = @CustomerId
                  and value > @K1 ) >= @Z1
                begin
                    set @Discount1 = 1
                end
        else
            if ( 2 not in (select DiscountType
                   from [Discount Details]
                   where CustomerId = @CustomerId)
            )

            if (select sum(value)
                from OrderValue OV
                join Orders O on OV.OrderId = O.OrderId
                where CustomerId = @CustomerId) >= @K2
                begin
                    set @Discount2 = 1
                end

        declare @OldPayment as int
        declare @newPayments as int

        set @newPayments = (select sum(MoneyPaid)
                            from Payments)

        set @OldPayment = (@newPayments - (select top 1 MoneyPaid
                                           from Payments
                                           order by DatePayment desc ))

        if ((@newPayments / @K4)- (@OldPayment / @K4) > 1)

            if (select sum(value)
                from OrderValue OV
                join Orders O on OV.OrderId = O.OrderId
                where CustomerId = @CustomerId) >= @K4
                begin
                    set @Discount4 = 1
                end
		declare  @counter AS INT
		set @counter = (select count(OrderId)
                from Orders
                where CustomerId = @CustomerId)
        if @counter%@Z3 = 0 AND
			@counter > 0
                begin
                    set @Discount3 = 1
                end
		SELECT *
		FROM (VALUES (@CustomerId,@Discount1,@Discount2,@Discount3,@Discount4)
			 ) t1 (klient, znizka1, znizka2, znizka3, znizka4)
END
go

create function GetEarnMoneyInPeriod(@dateFrom datetime, @dateTo datetime)
    returns money
as begin return (
        select sum(MoneyPaid)
        from Payments
        where DatePayment > @dateFrom and DatePayment < @dateTo)
    end
go

grant alter, control, execute, references, take ownership, view definition on GetEarnMoneyInPeriod to admin
go

CREATE function GetMenuStatsByDate(@dateFrom datetime, @dateTo datetime)
    returns table
        return
        select ProductName AS Dish, COUNT(md.MenuId) AS [times on menu], sum(PriceOfProduct) [SUM Price],
        avg(PriceOfProduct) [AVG Price],
        MAX(PriceOfProduct) [MAX Price], MIN(PriceOfProduct) [MIN Price]
        from Products p
        join [Menu Details] md on p.ProductId = md.ProductID
        join Menu M on md.MenuId = M.MenuId
        where m.StartedDate > @dateFrom and m.EndedDate < @dateTo
        group by ProductName
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on GetMenuStatsByDate to admin
go

grant select on GetMenuStatsByDate to employee
go

create function GetProductsBetweenDates(@startdate datetime, @enddate datetime)
returns table as
    return
    select ProductName
    from Products P
    inner join [Orders Details] [O D] on P.ProductId = [O D].ProductId
    inner join Orders O on O.OrderId = [O D].OrderId
    where OrderDate between @startdate and @enddate
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on GetProductsBetweenDates to admin
go

grant select on GetProductsBetweenDates to employee
go

CREATE function GetTop10Bestselers(@startdate datetime, @enddate datetime)
returns table as
    return
    select top 10 P.ProductID, ProductName, Sum(Quantity) as 'amount'
    from Products P
    inner join [Orders Details] [O D] on P.ProductId = [O D].ProductId
    inner join Orders O on [O D].OrderId = O.OrderId
    where OrderDate between @startdate and @enddate
    group by ProductName, P.ProductId
    order by COUNT([O D].ProductId) desc
go

grant alter, control, delete, insert, references, select, take ownership, update, view definition on GetTop10Bestselers to admin
go

grant select on GetTop10Bestselers to customer
go

CREATE function MenuCorrect(@id int)
returns bit
AS
BEGIN
    declare @items int
    declare @minProductsToChange int
    declare @previousId int
    set @previousId = (select MenuId from menu where StartedDate =
                                                    (select max(StartedDate) from menu where StartedDate < (select StartedDate from menu where MenuId = @id)))
    set @items = (
        select count(*)
        from (
            select ProductId
            from [Menu Details] md
--             where md.MenuId = (select top 1 m.MenuId as lastId
--                     from [Menu Details] as md
--                     inner join Menu m on md.MenuId = m.MenuId
--                     where m.StartedDate < (select m2.StartedDate
--                                          from Menu m2
--                                          where m2.MenuId = @id))
            where md.MenuId = @id

            except

            select ProductId
            from [Menu Details] md
            where md.MenuId = @previousId) out )

    set @minProductsToChange = (
        select count(*)
        from (
            select *
            from [Menu Details] md
--             where md.MenuId = (select top 1 m.MenuId as lastId
--                     from [Menu Details] as md
--                     inner join Menu m on md.MenuId = m.MenuId
--                     where m.StartedDate < (select m2.StartedDate
--                                          from Menu m2
--                                          where m2.MenuId = @id))
            where md.MenuId = @previousId
             ) out ) / 2

    if @items >= @minProductsToChange
    begin
        return 1
    end
    return 0
END
go

grant alter, control, execute, references, take ownership, view definition on MenuCorrect to admin
go

CREATE PROCEDURE RemoveFromMenu(
	@menuID AS INTEGER
	,@productID AS INTEGER
	,@price AS MONEY
)
AS
BEGIN
	DELETE FROM [Menu Details] WHERE [Menu Details] .MenuId = @menuID AND ProductID = @productID 

    DECLARE @valid AS BIT
	EXEC @valid =  dbo.MenuCorrect @id = @menuID
    IF @valid = 0
	BEGIN
		UPDATE Menu
			SET Valid = 0
			WHERE Menu.MenuId = @menuID
	END
END
go

grant alter, control, execute, take ownership, view definition on RemoveFromMenu to admin
go


	CREATE FUNCTION dbo.fn_diagramobjects() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'FUNCTION', 'fn_diagramobjects'
go

grant alter, control, execute, references, take ownership, view definition on fn_diagramobjects to admin
go

deny execute on fn_diagramobjects to guest
go

grant execute on fn_diagramobjects to [public]
go


	CREATE PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_alterdiagram'
go

grant alter, control, execute, take ownership, view definition on sp_alterdiagram to admin
go

deny execute on sp_alterdiagram to guest
go

grant execute on sp_alterdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_creatediagram'
go

grant alter, control, execute, take ownership, view definition on sp_creatediagram to admin
go

deny execute on sp_creatediagram to guest
go

grant execute on sp_creatediagram to [public]
go


	CREATE PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_dropdiagram'
go

grant alter, control, execute, take ownership, view definition on sp_dropdiagram to admin
go

deny execute on sp_dropdiagram to guest
go

grant execute on sp_dropdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE',
     'sp_helpdiagramdefinition'
go

grant alter, control, execute, take ownership, view definition on sp_helpdiagramdefinition to admin
go

deny execute on sp_helpdiagramdefinition to guest
go

grant execute on sp_helpdiagramdefinition to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_helpdiagrams'
go

grant alter, control, execute, take ownership, view definition on sp_helpdiagrams to admin
go

deny execute on sp_helpdiagrams to guest
go

grant execute on sp_helpdiagrams to [public]
go


	CREATE PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_renamediagram'
go

grant alter, control, execute, take ownership, view definition on sp_renamediagram to admin
go

deny execute on sp_renamediagram to guest
go

grant execute on sp_renamediagram to [public]
go


	CREATE PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_upgraddiagrams'
go

grant alter, control, execute, take ownership, view definition on sp_upgraddiagrams to admin
go


