ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_SECFee] DEFAULT ((0)) FOR [SECFee];

