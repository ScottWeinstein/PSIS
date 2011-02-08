USE [DemoDB]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExpandDateTime]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ExpandDateTime]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ExpandDateTime]
( 
 @ts as datetime2
)
RETURNS TABLE 
AS
RETURN 
(
 select @ts as DateTimeKey
   , year(@ts) Year
   , year(@ts) * 100 + ceiling(cast(month(@ts) AS decimal) / 3) QuarterKey
   , 'Q' + cast(ceiling(cast(month(@ts) AS decimal) / 3) AS varchar) + ' ' + cast(year(@ts) AS varchar) QuarterValue
   , year(@ts) * 100 + month(@ts) MonthKey
   , right('00' + convert(varchar, month(@ts)), 2) + '/' + cast(year(@ts) AS varchar) MonthValue
   , year(@ts) * 10000 + month(@ts) * 100 + Day(@ts) DayKey
   , convert(varchar(10),@ts,110) DayValue
   , year(@ts) * 1000000 + month(@ts) * 10000 + Day(@ts) * 100 + datepart(hour,@ts) HourKey
)

GO

