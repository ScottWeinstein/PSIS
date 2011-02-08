ALTER TABLE [dbo].[Trades]
    ADD CONSTRAINT [FK_Trades_Accounts] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Accounts] ([AccountId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

