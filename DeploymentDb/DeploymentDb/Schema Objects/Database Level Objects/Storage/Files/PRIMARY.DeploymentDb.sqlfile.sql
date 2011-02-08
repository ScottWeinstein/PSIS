ALTER DATABASE [$(DatabaseName)]
    ADD FILE (NAME = [DeploymentDb], FILENAME = '$(DefaultDataPath)DeploymentDb.mdf', SIZE = 2304 KB, FILEGROWTH = 1024 KB) TO FILEGROUP [PRIMARY];

