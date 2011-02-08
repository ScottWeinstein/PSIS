ALTER TABLE [dbo].[DeploymentLog]
    ADD CONSTRAINT [FK_DeploymentLog_TableScripts] FOREIGN KEY ([FileId]) REFERENCES [dbo].[TableScripts] ([FileId]) ON DELETE NO ACTION ON UPDATE NO ACTION;

