USE [DemoDb]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeploymentLog](
	[DeploymentId] [int] IDENTITY(1,1) NOT NULL,
	[FileId] [int] NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[ResultText] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
