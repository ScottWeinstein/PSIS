USE [DemoDB]
GO

/****** Object:  UserDefinedFunction [dbo].[StringTohierarchy]    Script Date: 11/05/2010 18:32:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StringTohierarchy]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[StringTohierarchy]
GO

USE [DemoDB]
GO

/****** Object:  UserDefinedFunction [dbo].[StringTohierarchy]    Script Date: 11/05/2010 18:32:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[StringTohierarchy]
(	
	@text nvarchar(max),
	@sep nvarchar(1)
)
RETURNS TABLE 
AS
RETURN 
(
	with Split as 
	(
		select t.P, tok.token 
		from (select @text as P) t
		cross apply dbo.Tokenize(t.P ,@sep)  tok
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
	
)

GO

