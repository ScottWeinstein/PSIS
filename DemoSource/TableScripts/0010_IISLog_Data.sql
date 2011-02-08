use DemoDB
go

truncate table [dbo].[IISLog]
go
INSERT INTO [dbo].[IISLog]
           ([Path]
           ,[User]
           ,[TimeStamp]
           )
select '/Meat','Scott', '2010-11-04 02:01:2' UNION ALL
select '/Meat/Poultry','Scott', '2010-11-05 02:01:22' UNION ALL
select '/Meat/Poultry/Chicken','Scott', '2010-11-05 12:01:3' UNION ALL
select '/Meat/Poultry/Chicken/Chicken with black bean sauce','Scott', '2010-11-04 02:2:32' UNION ALL
select '/Vegtables/Salad/Savory/Ceasar Salad','Scott', '2010-11-03 08:01:7' 
