ALTER DATABASE [$(DatabaseName)]
    ADD LOG FILE (NAME = [DeploymentDb_log], FILENAME = '$(DefaultLogPath)\DeploymentDb_log.LDF', SIZE = 576 KB, MAXSIZE = 2097152 MB, FILEGROWTH = 10 %);

