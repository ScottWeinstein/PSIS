USE [DemoDB]
GO

/****** Object:  View [dbo].[DimIISLogDate]    Script Date: 11/05/2010 14:08:57 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[DimIISLogDate]'))
DROP VIEW [dbo].[DimIISLogDate]
GO

USE [DemoDB]
GO

/****** Object:  View [dbo].[DimIISLogDate]    Script Date: 11/05/2010 14:08:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[DimIISLogDate] as
with DistinctTS as
(
 select distinct il.TimeStamp
 from dbo.IISLog il
)
select d.*
from DistinctTS
cross apply dbo.ExpandDateTime(TimeStamp) d

GO

