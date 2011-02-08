CREATE TABLE [DW].[FactTrades] (
    [TradeKey]         BIGINT   IDENTITY (1, 1) NOT NULL,
    [ExecutionTimeKey] DATETIME NOT NULL,
    [SideKey]          INT      NOT NULL,
    [SymbolKey]        INT      NOT NULL,
    [Price]            MONEY    NOT NULL,
    [Size]             FLOAT    NOT NULL,
    [ExchangeFee]      MONEY    NOT NULL,
    [BrokerFee]        MONEY    NOT NULL,
    [SECFee]           MONEY    NOT NULL,
    [MarginFee]        MONEY    NOT NULL
);

