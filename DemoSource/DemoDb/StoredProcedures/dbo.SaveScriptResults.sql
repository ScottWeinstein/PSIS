USE [DemoDb]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SaveScriptResults]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SaveScriptResults]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SaveScriptResults
		@fileName nvarchar(255),
		@resultText nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;
	declare @fid int
	set @fid = -1

	if not exists(select ts.FileId
		from dbo.TableScripts  ts where ts.Filename = @fileName)
	begin
		insert dbo.TableScripts (Filename) values (@fileName)
		set @fid = SCOPE_IDENTITY()
	end
	else
		select @fid=ts.FileId
		from dbo.TableScripts  ts where ts.Filename = @fileName

	insert dbo.DeploymentLog (FileId, ResultText) values (@fid,@resultText)
END
GO
