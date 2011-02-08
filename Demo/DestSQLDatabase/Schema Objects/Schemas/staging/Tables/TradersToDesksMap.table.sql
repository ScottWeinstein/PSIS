CREATE TABLE [staging].[TradersToDesksMap] (
    [ToDMapId] INT IDENTITY (1, 1) NOT NULL,
    [TraderId] INT NOT NULL,
    [DeskId]   INT NOT NULL
);

