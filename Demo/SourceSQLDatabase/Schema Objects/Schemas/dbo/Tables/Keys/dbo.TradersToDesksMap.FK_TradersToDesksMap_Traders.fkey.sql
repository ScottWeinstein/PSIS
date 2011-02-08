ALTER TABLE [dbo].[TradersToDesksMap]
    ADD CONSTRAINT [FK_TradersToDesksMap_Traders] FOREIGN KEY ([TraderId]) REFERENCES [dbo].[Traders] ([TraderId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

