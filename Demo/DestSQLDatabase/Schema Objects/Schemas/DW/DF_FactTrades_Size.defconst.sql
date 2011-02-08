ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_Size] DEFAULT ((0)) FOR [Size];

