ALTER TABLE [dbo].[Trades]
    ADD CONSTRAINT [FK_Trades_TradersToDesksMap] FOREIGN KEY ([TraderDeskMapId]) REFERENCES [dbo].[TradersToDesksMap] ([ToDMapId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

