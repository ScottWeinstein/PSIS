ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_MarginFee] DEFAULT ((0)) FOR [MarginFee];

