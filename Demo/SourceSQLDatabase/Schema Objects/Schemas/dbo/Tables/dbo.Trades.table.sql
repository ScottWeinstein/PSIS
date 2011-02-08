CREATE TABLE [dbo].[Trades] (
    [ExecutionId]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [TimeStamp]       DATETIME      NOT NULL,
    [Side]            NVARCHAR (50) NOT NULL,
    [TraderDeskMapId] INT           NOT NULL,
    [SymbolId]        INT           NOT NULL,
    [CustomerId]      INT           NOT NULL,
    [Price]           MONEY         NOT NULL,
    [Size]            FLOAT         NOT NULL
);

