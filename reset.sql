EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'DemoDB'
GO
USE [master]
GO
ALTER DATABASE [DemoDB] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
USE [master]
GO
DROP DATABASE [DemoDB]
GO

delete DeploymentDb.dbo.DeploymentLog
delete DeploymentDb.dbo.TableScripts
