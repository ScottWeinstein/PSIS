USE [DemoDB]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DimIISPaths]'))
DROP VIEW [dbo].[DimIISPaths]
GO

create view dbo.DimIISPaths
as
with DPath as 
(
 select distinct lower(Substring(il.Path,2,len(il.Path))) P from dbo.IISLog il
)
select H.* from 
DPath
cross apply dbo.StringTohierarchy(P,'/') H
union all
select '/',null,null,null,null
