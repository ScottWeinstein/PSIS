CREATE VIEW [dbo].[TradeDWView]
	AS SELECT tr.ExecutionId
		, Symbols.Symbol
		,Symbols.FullName
		,Accounts.AccountName  
		,DeskName
		,TraderName
		,tr.TimeStamp
		,tr.Side
		,tr.Price
		,tr.Size
	FROM dbo.Trades tr
	inner join dbo.TradersToDesksMap tdm on tdm.ToDMapId = tr.TraderDeskMapId
	inner join dbo.Desks on Desks.DeskId = tdm.DeskId
	inner join dbo.Traders on traders.TraderId = tdm.TraderId
	inner join dbo.Accounts on Accounts.AccountId = tr.CustomerId
	inner join dbo.Symbols on Symbols.SymbolId=  tr.SymbolId
