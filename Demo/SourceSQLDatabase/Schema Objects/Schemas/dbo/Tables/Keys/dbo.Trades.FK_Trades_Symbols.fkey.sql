ALTER TABLE [dbo].[Trades]
    ADD CONSTRAINT [FK_Trades_Symbols] FOREIGN KEY ([SymbolId]) REFERENCES [dbo].[Symbols] ([SymbolId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

