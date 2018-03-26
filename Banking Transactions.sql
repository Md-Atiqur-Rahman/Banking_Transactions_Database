
--1.Create a Non-Clustered index
--2.Create a Store procedure to insert data
--3.Create a View show the all information
--4.Create a function to display total Balance of each user accountnumber
--5.Create a Table Valued function to display total Details of customer through  each user accountnumber
--6.Create a trigger When user will deposit balance, deposit balance will be added with previous balance, 
--  in same way when user will withdraw balance the withdraw balance will be reduce from previous balance
--  but also restricted  user can not withdraw less than 500 and
--  also restricted user can withdraw balance until previous balance is 500 
--7. insert a values with a view using trigger

create database Bank
go
use Bank
go
create table branch
(
id int  identity(1,1) primary key,
Branch_name varchar(100) not null,
Branch_city varchar(100),
)
GO

create table account
(Id int IDENTITY(1,1) NOT NULL,
Account_number char(50) not null primary key,
brid int references branch(ID),
Balance money,
[Status] varchar(50) check([Status] in('Deposit','Withdraw')) ,
)
go
create table Account_Holder
(
Name varchar(50) not null primary key,
[Address] varchar(50),
City varchar(20),
Phone varchar (20) unique 

)
go
create table  depositor
(
Id int identity primary key,
Name varchar(50) references Account_Holder(Name),
Account_number char(50) references account(account_number),

)

--2.Create a Non-Clustered index
go
create nonclustered index Indcustomer on Account_Holder(Name)

--3.Using  Store procedure to insert in  All the table 
go
create proc SpInsertbranch @branch_name varchar(100) ,
						   @branch_city varchar(100)
						   
					 as
begin 
begin try 
insert into branch values (@branch_name,@branch_city)

end try
begin catch
declare @er varchar(200)
set @er=error_message()
raiserror(@er,10,1)
return error_number()
end catch
end
go


exec SpInsertbranch 'Dewanhat', 'Chittagong'
exec SpInsertbranch 'Halishahar', 'Chittagong'
exec SpInsertbranch 'Dhanmondi', 'Dhaka '
exec SpInsertbranch 'Elephant Road', 'Dhaka '
exec SpInsertbranch 'Mirpur', 'Dhaka '
exec SpInsertbranch 'Jhalakathi', 'Barisal'
exec SpInsertbranch 'Kurigram', 'Rangpur'
exec SpInsertbranch 'Benapole', 'Jessore'
GO
select * From branch
go


create proc SpInsertAccount @account_number char(50) ,
							@branchid int,
							@balance money,
							@Status varchar(50)='Deposit'
							
					 as
begin 
begin try 
insert into account values (@account_number,@branchid,@balance,@Status)

end try
begin catch
declare @er varchar(200)
set @er=error_message()
raiserror(@er,10,1)
return error_number()
end catch
end
GO
exec SpInsertAccount	'A-101', 1, 5000
exec SpInsertAccount	'A-102', 2, 4000
exec SpInsertAccount	'A-201', 3, 9000
exec SpInsertAccount	'A-215', 4, 7000
exec SpInsertAccount	'A-217', 6, 7500
exec SpInsertAccount	'A-305', 7, 7500
GO
select * From account
go
create proc SpInsertAccount_Holder	 @Name varchar(50) ,
									 @Address varchar(50),
									 @City varchar(20),
									 @phone varchar(20)
as
begin 
	begin try 
	insert into Account_Holder values (@Name,@Address,@City,@phone)

	end try
	begin catch
	declare @er varchar(200)
	set @er=error_message()
	raiserror(@er,10,1)
	return error_number()
	end catch
end

go
exec SpInsertAccount_Holder 'Himel',		'Agrabad',			'Chittagong',	'01815648616'
exec SpInsertAccount_Holder 'Sumon',		'Boropol',			'Chittagong',	'01813285222'
exec SpInsertAccount_Holder 'Sorif',		'Dhanmondi-32',		'Dhaka',		'01670043742'
exec SpInsertAccount_Holder 'Mim',		    'Jhalakathi',		'Barisal',		'01683810270'
exec SpInsertAccount_Holder 'Raju',			'Benapole',			'Jessore',		'01991660332'
exec SpInsertAccount_Holder 'Tanvir',		'Elephant Road',	'Dhaka',		'01733450254'
exec SpInsertAccount_Holder 'Sahanaj Begum', 'Kurigram',		'Rangpur',		'01923481267'
GO
select * From Account_Holder
go
create proc SpInsertdepositor	@Name varchar(50) ,
								@account_number char(50) 
								as
begin 
	begin try 
	insert into depositor values (@Name,@account_number)

	end try
	begin catch
	declare @er varchar(200)
	set @er=error_message()
	raiserror(@er,10,1)
	return error_number()
	end catch
end
go
exec SpInsertdepositor 'Himel', 'A-101'
exec SpInsertdepositor 'Sumon', 'A-102'
exec SpInsertdepositor 'Sorif', 'A-201'
exec SpInsertdepositor 'Mim',	'A-217'
exec SpInsertdepositor 'Raju',  'A-222'
exec SpInsertdepositor 'Tanvir','A-215'
exec SpInsertdepositor 'Sahanaj Begum','A-305'
GO
select * From depositor
go


--4.Create a View show the  information
create view [dbo].[Vw_All]
as
select a.Account_number,a.Balance,c.Name,c.City,c.[Address],c.Phone ,a.[brid],
a.[Status]
from  account a
inner join depositor d
on d.account_number= a.account_number
inner join Account_Holder c
on c.Name=d.name
GO
select * From [Vw_All]
go

--5.Create a function to display total Balance of each user accountnumber
create function FnTolalBalance (@AccountNumber varchar(50))
returns money
as
Begin
return (select a.Balance  from account a where a.Account_number=@AccountNumber)
End
go
select dbo.FnTolalBalance ('A-101')as 'TolalBalance' 
go

--6.Create a Table Valued function to display total Details of customer through  each user accountnumber
create function FnTolalDetails (@AccountNumber varchar(50))
returns Table
as
return (select a.Account_number,a.Balance,c.Name,c.City,c.Address,c.Phone ,b.Branch_city,b.Branch_name
from branch b
inner join account a
on  b.[id]= a.[brid]
inner join depositor d
on d.account_number= a.account_number
inner join Account_Holder c
on c.Name=d.name where a.Account_number=@AccountNumber)

go
select * from FnTolalDetails ('A-101')



--	  Create a trigger When user will deposit balance, deposit balance will be added with previous balance, 
--    in same way when user will withdraw balance the withdraw balance will be reduce from previous balance
--    but also restricted  user can not withdraw less than 500 and
--    also restricted user can withdraw balance until previous balance is 500 

go

create TRIGGER TrUPDATE
ON account
for  UPDATE
AS
DECLARE @crramt INT,@id varchar(150),@pre int,@withdraw varchar(20),@deposit varchar(20)
select @pre = Balance from deleted
SELECT @crramt = Balance FROM inserted
select @id= Account_number from inserted
select @withdraw = [Status] from inserted 
select @deposit = [Status] from inserted

	 if update(Balance)
		begin
			if  @withdraw='withdraw'
				begin
					IF @crramt <= 500
						BEGIN
						RAISERROR ('can not withdraw less then 500', 11, 1)
						ROLLBACK
						END
				if(@pre-@crramt)<500
						BEGIN
						RAISERROR ('You can''t withdraw,balance will be less then 500', 11, 1)
						ROLLBACK
						END
					update  account set Balance= @pre -i.Balance 
					from Inserted i join account
					on i.Account_number= account.Account_number

					
				end
			else if @deposit='deposit'
				begin
					update  account set Balance=@pre +i.Balance 
					from Inserted i join account
					on i.Account_number= account.Account_number
					
				end
		End

 
 go
 --if any accountHolder want to withdraw money the money will be Added of previous balance and show 'deposit' in status cloumn
 Update  account set Balance=500 ,  [Status] = 'Deposit' where Account_number='A-101' 
 go
--if any accountHolder want to withdraw money the money will be diductated of previous balance and show 'withdraw' in status cloumn
Update  account set Balance=1000 ,  [Status] = 'Withdraw' where Account_number='A-101' 
  
 go
 --any accountHolder cant not withdraw less then 500 taka if wants will show error
 --Update  account set Balance=499 ,  [Status] = 'withdraw' where Account_number='A-101' --error


go
--insert a values with a view using trigger

create trigger TRVw on Vw_All
instead of insert 
as
begin 
      
    insert into account(account_number,[brid],balance,[status])
       select 
           account_number,[brid],balance,[Status]
       from inserted
	   if not exists(select a.Name from  Account_Holder  a join inserted
	   on a.Name=inserted.Name  )
	   begin
			insert into Account_Holder(Name,[Address],City,Phone)
		   select 
			   Name,[Address],City,Phone
		   from inserted
	   end
		if Not Exists (select depositor.[Account_number] from depositor
		join inserted  on depositor.Account_number=inserted.Account_number)
		begin
			insert into depositor(Name,[Account_number])
		   select      Name,[Account_number]    from inserted
	   end
	  -- rollback transaction
end
go
insert into Vw_All values ('C-404',4000,'Lira','Chittagong','Boropul','01717366575',5,'Deposit')
GO
select * From branch
select * from account
select * From Account_Holder
select * from depositor
select * from Vw_All
go
