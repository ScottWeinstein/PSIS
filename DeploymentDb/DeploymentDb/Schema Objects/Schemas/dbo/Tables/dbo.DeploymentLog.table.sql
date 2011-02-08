CREATE TABLE [dbo].[DeploymentLog] (
    [DeploymentId] INT            IDENTITY (1, 1) NOT NULL,
    [FileId]       INT            NOT NULL,
    [Timestamp]    DATETIME       NOT NULL,
    [ResultText]    NVARCHAR (MAX) NOT NULL
);

