USE [DemoDb]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HasScriptBeenRun]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[HasScriptBeenRun]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION HasScriptBeenRun
(	
	@fileName nvarchar(255)
)
RETURNS TABLE 
AS
RETURN 
(
	select cast(isnull(sum(1),0) as bit) val
	from dbo.TableScripts ts
	inner join dbo.DeploymentLog dl on dl.FileId = ts.FileId
	where ts.Filename = @fileName )
GO
