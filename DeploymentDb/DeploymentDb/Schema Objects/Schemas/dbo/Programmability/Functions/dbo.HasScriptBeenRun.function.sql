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