CREATE TABLE [dbo].[Symbols] (
    [SymbolId] INT            IDENTITY (1, 1) NOT NULL,
    [Symbol]   VARCHAR (20)   NOT NULL,
    [FullName] NVARCHAR (500) NOT NULL,
    [Exchange] NVARCHAR (50)  NOT NULL
);

