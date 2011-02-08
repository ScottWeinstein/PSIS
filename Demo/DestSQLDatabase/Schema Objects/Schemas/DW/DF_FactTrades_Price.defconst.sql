ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_Price] DEFAULT ((0)) FOR [Price];

