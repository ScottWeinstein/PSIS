USE [DemoDB]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_IISLog_Path]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[IISLog] DROP CONSTRAINT [DF_IISLog_Path]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_IISLog_User]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[IISLog] DROP CONSTRAINT [DF_IISLog_User]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_IISLog_TimeStamp]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[IISLog] DROP CONSTRAINT [DF_IISLog_TimeStamp]
END

GO

USE [DemoDB]
GO

/****** Object:  Table [dbo].[IISLog]    Script Date: 11/05/2010 13:06:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IISLog]') AND type in (N'U'))
DROP TABLE [dbo].[IISLog]
GO

USE [DemoDB]
GO

/****** Object:  Table [dbo].[IISLog]    Script Date: 11/05/2010 13:06:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IISLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Path] [nvarchar](max) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[TimeStamp] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_IISLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[IISLog] ADD  CONSTRAINT [DF_IISLog_Path]  DEFAULT ('') FOR [Path]
GO

ALTER TABLE [dbo].[IISLog] ADD  CONSTRAINT [DF_IISLog_User]  DEFAULT ('') FOR [User]
GO

ALTER TABLE [dbo].[IISLog] ADD  CONSTRAINT [DF_IISLog_TimeStamp]  DEFAULT (getdate()) FOR [TimeStamp]
GO

