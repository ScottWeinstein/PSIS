ALTER TABLE [DW].[FactTrades]
    ADD CONSTRAINT [DF_FactTrades_BrokerFee] DEFAULT ((0)) FOR [BrokerFee];

