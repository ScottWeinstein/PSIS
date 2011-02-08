CREATE TABLE [DW].[DimSymbol] (
    [SymbolKey]   INT            IDENTITY (1, 1) NOT NULL,
    [SymbolValue] NVARCHAR (50)  NOT NULL,
    [FullName]    NVARCHAR (150) NOT NULL
);



