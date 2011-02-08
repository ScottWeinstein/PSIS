USE [DemoDb]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[DeploymentLog]') AND name = N'PK_DeploymentLog')
ALTER TABLE [dbo].[DeploymentLog] ADD  CONSTRAINT [PK_DeploymentLog] PRIMARY KEY CLUSTERED 
(
	[DeploymentId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeploymentLog_TableScripts]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeploymentLog]'))
ALTER TABLE [dbo].[DeploymentLog]  WITH CHECK ADD  CONSTRAINT [FK_DeploymentLog_TableScripts] FOREIGN KEY([FileId])
REFERENCES [TableScripts] ([FileId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DeploymentLog_TableScripts]') AND parent_object_id = OBJECT_ID(N'[dbo].[DeploymentLog]'))
ALTER TABLE [dbo].[DeploymentLog] CHECK CONSTRAINT [FK_DeploymentLog_TableScripts]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_DeploymentLog_Timestamp]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DeploymentLog] ADD  CONSTRAINT [DF_DeploymentLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_DeploymentLog_ErrorText]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DeploymentLog] ADD  CONSTRAINT [DF_DeploymentLog_ErrorText]  DEFAULT ('') FOR [ResultText]
END

GO
