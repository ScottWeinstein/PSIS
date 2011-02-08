ALTER TABLE [dbo].[DeploymentLog]
    ADD CONSTRAINT [DF_DeploymentLog_Timestamp] DEFAULT (getdate()) FOR [Timestamp];

