CREATE VIEW [dbo].[DeploymentStatus]
	AS SELECT 
			ts.Filename
		,	dl.Timestamp
		,	dl.ResultText 
	FROM dbo.DeploymentLog dl
	inner join dbo.TableScripts ts on ts.FileId = dl.FileId