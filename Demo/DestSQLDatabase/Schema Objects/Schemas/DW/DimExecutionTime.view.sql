
create view DW.DimExecutionTime as 
	select distinct ExecutionTimeKey from DestSQLDatabase.DW.FactTrades