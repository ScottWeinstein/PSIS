ALTER TABLE [dbo].[TradersToDesksMap]
    ADD CONSTRAINT [FK_TradersToDesksMap_Desks] FOREIGN KEY ([DeskId]) REFERENCES [dbo].[Desks] ([DeskId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

