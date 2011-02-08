USE [DemoDB]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DimIISPaths_Bad]'))
DROP VIEW [dbo].[DimIISPaths_Bad]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[DimIISPaths_Bad] as 
with DPath as 
(
 select distinct lower(Substring(il.Path,2,len(il.Path))) P from dbo.IISLog il
)
, Split as
( 
 select DPath.P, tok.token 
 from DPath
 cross apply dbo.Tokenize(P ,'/')  tok
)
, PathSplitSeq as
(
 select Split.P
   ,Split.token
   , ROW_NUMBER() over(partition by Split.P order by Split.P) as Seq 
 from Split 
)
, pivotedPaths AS 
(
 select '/' + P as WeblogPathValue
   , [1] AS L1
   , [2] AS L2
   , [3] AS L3
   , [4] as L4
from  PathSplitSeq
PIVOT (
  Max(token) FOR seq IN ([1],[2],[3],[4]) 
 ) as piv
)
select * from pivotedPaths
union all
select '/',null,null,null,null

GO

