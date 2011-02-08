ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_ExchangeFee] DEFAULT ((0)) FOR [ExchangeFee];

