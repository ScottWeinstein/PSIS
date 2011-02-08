ALTER TABLE [dbo].[DeploymentLog]
    ADD CONSTRAINT [DF_DeploymentLog_ErrorText] DEFAULT ('') FOR [ResultText];

